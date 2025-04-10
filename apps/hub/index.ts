import { PublicKey } from "@solana/web3.js";
import { randomUUIDv7, type ServerWebSocket} from "bun";
import type {IncomingMessage, SignupIncomingMessage} from "common/types"
import nacl from "tweetnacl";
import { decodeUTF8 } from "tweetnacl-util";
import { prismaClient } from "db/client"

const availableValidators: { validatorId: string, socket: ServerWebSocket<unknown>, publicKey: string }[] = [];

const CALLBACKS : { [callbackId: string]: (data: IncomingMessage) => void} = {};
const COST_PER_VALIDATION = 100 // lamports


Bun.serve({
  fetch(req, server) {
    if (server.upgrade(req)) {
      return;
    }
    return new Response("Upgrade failed", { status: 500 });
  },
  port: 8081,
  websocket: {
    async message(ws: ServerWebSocket<unknown>, message: string) {
      try {
        const data: IncomingMessage = JSON.parse(message);
        
        console.log("Received message type:", data.type);
        console.log("Message data:", JSON.stringify(data.data || {}));
        
        if (data.type === 'signup') {
          // Signup handler code remains the same
          const verified = await verifyMessage(
            `Signed message for ${data.data?.callbackId}, ${data.data?.publicKey}`,
            data.data?.publicKey,
            data.data?.signedMessage
          );
    
          if (verified) {
            await signupHandler(ws, data.data);
          }
        } else if (data.type === 'validate') {
          const callbackId = data.data?.callbackId;
          console.log("Looking for callback with ID:", callbackId);
          
          if (callbackId && typeof CALLBACKS[callbackId] === 'function') {
            console.log("Callback found, executing...");
            CALLBACKS[callbackId](data);
            delete CALLBACKS[callbackId];
          } else {
            console.error("No valid callback found for validate message:", 
              callbackId ? `ID ${callbackId} not found` : "callbackId is undefined");
          }
        } else {
          console.warn(`Unknown message type: ${data}`);
        }
      } catch (error) {
        console.error("Error processing WebSocket message:", error);
      }
    },
    async close(ws: ServerWebSocket<unknown>) {
      availableValidators.splice(availableValidators.findIndex(x => x.socket === ws), 1);
    }
  }, // handlers
});

async function verifyMessage(message: string, publicKey: string, signature: string) {
  const messageBytes = decodeUTF8(message);
  const result = nacl.sign.detached.verify(
    messageBytes,
    new Uint8Array(JSON.parse(signature)),
    new PublicKey(publicKey).toBytes(),
  )

  return result;
}

async function signupHandler(ws: ServerWebSocket<unknown>, { ip, publicKey, signedMessage, callbackId }: SignupIncomingMessage) {
  const validatorDb = await prismaClient.validator.findFirst({
    where: { publicKey },
  });

  if(validatorDb) {
    ws.send(JSON.stringify({
      type: 'signup',
      data: {
        validatorId: validatorDb.id,
        callbackId
      }
    }));

    availableValidators.push({
      validatorId: validatorDb.id,
      socket: ws,
      publicKey: validatorDb.publicKey,
    })

    return;
  }

  //TODO: Given the ip, return the location
  const validator = await prismaClient.validator.create({
    data: {
      ip,
      publicKey,
      location: "unknown",
    }
  })

  ws.send(JSON.stringify({
    type: 'signup',
    data: {
      validator: validator.id,
      callbackId,
    }
  }));

  availableValidators.push({
    validatorId: validator.id,
    socket: ws,
    publicKey: validator.publicKey,
  });

}

setInterval(async () => {
  const websiteToMonitor = await prismaClient.website.findMany({
    where: { disabled: false },
  });

  for (const website of websiteToMonitor) {
    availableValidators.forEach(validator => {
      const callbackId = randomUUIDv7();
      console.log(`Sending validate to ${validator.validatorId} ${website.url}`);
      validator.socket.send(JSON.stringify({
        type: 'validate',
        data: {
          url: website.url,
          callbackId,
        }
      }));

      CALLBACKS[callbackId] = async (data: IncomingMessage) => {
        if(data.type === 'validate') {
          const { validatorId, status, latency, signedMessage } = data.data;
          const verified = await verifyMessage(
            `Replying to ${callbackId}`,
            validator.publicKey,
            signedMessage
          );

          if (!verified) {
            return;
          }

          await prismaClient.$transaction(async (tx) => {
            await tx.websiteTick.create({
              data: {
                websiteId: website.id,
                validatorId,
                status,
                latency,
                createdAt: new Date(),
              }
            })

            await tx.validator.update({
              where: {id: validatorId},
              data: {
                pendingPayouts: {increment: COST_PER_VALIDATION},
              }
            })
          })
        }
      }
    });
  }
}, 60 * 1000);