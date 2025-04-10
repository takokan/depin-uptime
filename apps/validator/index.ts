import { Keypair } from "@solana/web3.js";
import { randomUUIDv7 } from "bun";
import type { OutgoingMessage, SignupOutgoingMessage, ValidateOutgoingMessage } from "common/types"
import nacl from "tweetnacl";
import { decodeUTF8 } from "tweetnacl-util";

const CALLBACKS: { [callbackId: string]: (data: SignupOutgoingMessage) => void} = {};
let validatorId: string | null = null;

async function main() {
  const keypair = Keypair.fromSecretKey(
    Uint8Array.from(JSON.parse(process.env.PRIVATE_KEY!))
  );

  const ws = new WebSocket("ws://localhost:8081");


  ws.onmessage = async (event) => {
    const data: OutgoingMessage = JSON.parse(event.data);
    if (data.type === 'signup') {
      CALLBACKS[data.data.callbackId]?.(data.data)
      delete CALLBACKS[data.data.callbackId];
    } else if (data.type === 'validate') {
      await validateHandler(ws, data.data, keypair);
    }
  }

  ws.onopen = async () => {
    const callbackId = randomUUIDv7();
    CALLBACKS[callbackId] = (data: SignupOutgoingMessage) => {
        validatorId = data.validatorId;
    }
    const signedMessage = await signMessage(`Signed message for ${callbackId}, ${keypair.publicKey}`, keypair);

    ws.send(JSON.stringify({
        type: 'signup',
        data: {
            callbackId,
            ip: '127.0.0.1',
            publicKey: keypair.publicKey,
            signedMessage,
        },
    }));
  }
}


async function validateHandler(ws: WebSocket, { url, callbackId, websiteId} : ValidateOutgoingMessage, keypair: Keypair) {
  console.log(`Validating ${url}`);

  const startTime = Date.now();
  const signature = await signMessage(`Replying to ${callbackId}`, keypair);


  try {
    const response = await fetch(url);
    const endTime = Date.now();
    const latency = endTime - startTime;
    const status = response.status;


    console.log(url);
    console.log(status);

    ws.send(JSON.stringify({
      type: 'validate',
      data: {
        callbackId, 
        status: status === 200 ? 'GOOD' : 'BAD',
        latency, 
        websiteId, 
        validatorId,
        signedMessage: signature
      }
    }));
  } catch (error) {
    ws.send(JSON.stringify({
      type: 'validate',
      data: {
          callbackId,
          status:'Bad',
          latency: 1000,
          websiteId,
          validatorId,
          signedMessage: signature,
      },
    }));
    console.log(error);
  }
}

async function signMessage(message: string, keypair: Keypair) {
  const messageBytes = decodeUTF8(message);
  const signature = nacl.sign.detached(messageBytes, keypair.secretKey);


  return JSON.stringify(Array.from(signature));
}

main();

setInterval(async () => {
  
}, 10000);