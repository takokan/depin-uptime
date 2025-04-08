-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'VALIDATOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "NodeStatus" AS ENUM ('PENDING', 'ACTIVE', 'INACTIVE', 'BANNED');

-- CreateEnum
CREATE TYPE "CheckStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'DISPUTED');

-- CreateEnum
CREATE TYPE "StakingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'UNSTAKED');

-- CreateEnum
CREATE TYPE "RewardStatus" AS ENUM ('PENDING', 'PAID', 'FAILED');

-- CreateEnum
CREATE TYPE "AlertStatus" AS ENUM ('ACTIVE', 'RESOLVED', 'ACKNOWLEDGED');

-- CreateEnum
CREATE TYPE "SubscriptionPlan" AS ENUM ('FREE', 'BASIC', 'PRO', 'ENTERPRISE');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('UNPAID', 'PENDING', 'PAID', 'FAILED', 'REFUNDED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'USER',
    "isEmailVerified" BOOLEAN NOT NULL DEFAULT false,
    "walletAddress" TEXT,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Website" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "checkInterval" INTEGER NOT NULL DEFAULT 300,
    "expectedStatus" INTEGER NOT NULL DEFAULT 200,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "userId" TEXT NOT NULL,
    "alertThreshold" INTEGER NOT NULL DEFAULT 2,
    "customHeaders" JSONB,

    CONSTRAINT "Website_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonitoringOptions" (
    "id" TEXT NOT NULL,
    "websiteId" TEXT NOT NULL,
    "timeout" INTEGER NOT NULL DEFAULT 30,
    "followRedirects" BOOLEAN NOT NULL DEFAULT true,
    "validateSSL" BOOLEAN NOT NULL DEFAULT true,
    "verifyContent" BOOLEAN NOT NULL DEFAULT false,
    "contentPattern" TEXT,
    "monitoringRegions" TEXT[],

    CONSTRAINT "MonitoringOptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ValidatorNode" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "ipAddress" TEXT,
    "walletAddress" TEXT NOT NULL,
    "nodeUrl" TEXT NOT NULL,
    "status" "NodeStatus" NOT NULL DEFAULT 'ACTIVE',
    "totalStake" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "reputationScore" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "lastHeartbeat" TIMESTAMP(3),
    "userId" TEXT,
    "region" TEXT NOT NULL DEFAULT 'global',
    "version" TEXT,

    CONSTRAINT "ValidatorNode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonitoringCheck" (
    "id" TEXT NOT NULL,
    "websiteId" TEXT NOT NULL,
    "validatorNodeId" TEXT NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "status" "CheckStatus" NOT NULL DEFAULT 'PENDING',
    "ipAssigned" TEXT,

    CONSTRAINT "MonitoringCheck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonitoringResult" (
    "id" TEXT NOT NULL,
    "websiteId" TEXT NOT NULL,
    "validatorNodeId" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responseTime" INTEGER,
    "statusCode" INTEGER,
    "isUp" BOOLEAN NOT NULL,
    "errorMessage" TEXT,
    "responseSize" INTEGER,
    "sslDetails" JSONB,
    "headers" JSONB,
    "userId" TEXT,
    "blockNumber" INTEGER,
    "txHash" TEXT,
    "contentMatch" BOOLEAN,
    "region" TEXT,

    CONSTRAINT "MonitoringResult_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StakingRecord" (
    "id" TEXT NOT NULL,
    "validatorNodeId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "txHash" TEXT NOT NULL,
    "blockNumber" INTEGER NOT NULL,
    "status" "StakingStatus" NOT NULL DEFAULT 'PENDING',

    CONSTRAINT "StakingRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ValidationReward" (
    "id" TEXT NOT NULL,
    "validatorNodeId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "txHash" TEXT,
    "blockNumber" INTEGER,
    "status" "RewardStatus" NOT NULL DEFAULT 'PENDING',
    "description" TEXT,

    CONSTRAINT "ValidationReward_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConsensusData" (
    "id" TEXT NOT NULL,
    "blockNumber" INTEGER NOT NULL,
    "blockHash" TEXT NOT NULL,
    "dataHash" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "validatorCount" INTEGER NOT NULL,
    "networkState" JSONB,

    CONSTRAINT "ConsensusData_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NotificationConfig" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "email" BOOLEAN NOT NULL DEFAULT true,
    "slack" BOOLEAN NOT NULL DEFAULT false,
    "telegram" BOOLEAN NOT NULL DEFAULT false,
    "discord" BOOLEAN NOT NULL DEFAULT false,
    "pushover" BOOLEAN NOT NULL DEFAULT false,
    "webhook" BOOLEAN NOT NULL DEFAULT false,
    "webhookUrl" TEXT,
    "slackWebhook" TEXT,
    "telegramChatId" TEXT,
    "discordWebhook" TEXT,
    "pushoverKey" TEXT,

    CONSTRAINT "NotificationConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Alert" (
    "id" TEXT NOT NULL,
    "websiteId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),
    "status" "AlertStatus" NOT NULL DEFAULT 'ACTIVE',
    "notified" BOOLEAN NOT NULL DEFAULT false,
    "notifiedAt" TIMESTAMP(3),

    CONSTRAINT "Alert_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApiKey" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "ApiKey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Subscription" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "plan" "SubscriptionPlan" NOT NULL DEFAULT 'FREE',
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "maxWebsites" INTEGER NOT NULL DEFAULT 5,
    "maxCheckInterval" INTEGER NOT NULL DEFAULT 60,
    "autoRenew" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_walletAddress_key" ON "User"("walletAddress");

-- CreateIndex
CREATE UNIQUE INDEX "MonitoringOptions_websiteId_key" ON "MonitoringOptions"("websiteId");

-- CreateIndex
CREATE UNIQUE INDEX "ValidatorNode_walletAddress_key" ON "ValidatorNode"("walletAddress");

-- CreateIndex
CREATE UNIQUE INDEX "ValidatorNode_nodeUrl_key" ON "ValidatorNode"("nodeUrl");

-- CreateIndex
CREATE UNIQUE INDEX "StakingRecord_txHash_key" ON "StakingRecord"("txHash");

-- CreateIndex
CREATE UNIQUE INDEX "ConsensusData_blockHash_key" ON "ConsensusData"("blockHash");

-- CreateIndex
CREATE UNIQUE INDEX "NotificationConfig_userId_key" ON "NotificationConfig"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKey_key_key" ON "ApiKey"("key");

-- CreateIndex
CREATE UNIQUE INDEX "Subscription_userId_key" ON "Subscription"("userId");

-- AddForeignKey
ALTER TABLE "Website" ADD CONSTRAINT "Website_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringOptions" ADD CONSTRAINT "MonitoringOptions_websiteId_fkey" FOREIGN KEY ("websiteId") REFERENCES "Website"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ValidatorNode" ADD CONSTRAINT "ValidatorNode_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringCheck" ADD CONSTRAINT "MonitoringCheck_websiteId_fkey" FOREIGN KEY ("websiteId") REFERENCES "Website"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringCheck" ADD CONSTRAINT "MonitoringCheck_validatorNodeId_fkey" FOREIGN KEY ("validatorNodeId") REFERENCES "ValidatorNode"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringResult" ADD CONSTRAINT "MonitoringResult_websiteId_fkey" FOREIGN KEY ("websiteId") REFERENCES "Website"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringResult" ADD CONSTRAINT "MonitoringResult_validatorNodeId_fkey" FOREIGN KEY ("validatorNodeId") REFERENCES "ValidatorNode"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MonitoringResult" ADD CONSTRAINT "MonitoringResult_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StakingRecord" ADD CONSTRAINT "StakingRecord_validatorNodeId_fkey" FOREIGN KEY ("validatorNodeId") REFERENCES "ValidatorNode"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ValidationReward" ADD CONSTRAINT "ValidationReward_validatorNodeId_fkey" FOREIGN KEY ("validatorNodeId") REFERENCES "ValidatorNode"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ValidationReward" ADD CONSTRAINT "ValidationReward_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NotificationConfig" ADD CONSTRAINT "NotificationConfig_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Alert" ADD CONSTRAINT "Alert_websiteId_fkey" FOREIGN KEY ("websiteId") REFERENCES "Website"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Alert" ADD CONSTRAINT "Alert_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiKey" ADD CONSTRAINT "ApiKey_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
