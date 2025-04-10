/*
  Warnings:

  - You are about to drop the column `createdAt` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `isEmailVerified` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `name` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `passwordHash` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `role` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `walletAddress` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `alertThreshold` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `checkInterval` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `customHeaders` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `description` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `expectedStatus` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `isActive` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `name` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Website` table. All the data in the column will be lost.
  - You are about to drop the `Alert` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ApiKey` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ConsensusData` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `MonitoringCheck` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `MonitoringOptions` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `MonitoringResult` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `NotificationConfig` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `StakingRecord` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Subscription` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ValidationReward` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ValidatorNode` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "WebsiteStatus" AS ENUM ('Good', 'Bad');

-- DropForeignKey
ALTER TABLE "Alert" DROP CONSTRAINT "Alert_userId_fkey";

-- DropForeignKey
ALTER TABLE "Alert" DROP CONSTRAINT "Alert_websiteId_fkey";

-- DropForeignKey
ALTER TABLE "ApiKey" DROP CONSTRAINT "ApiKey_userId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringCheck" DROP CONSTRAINT "MonitoringCheck_validatorNodeId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringCheck" DROP CONSTRAINT "MonitoringCheck_websiteId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringOptions" DROP CONSTRAINT "MonitoringOptions_websiteId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringResult" DROP CONSTRAINT "MonitoringResult_userId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringResult" DROP CONSTRAINT "MonitoringResult_validatorNodeId_fkey";

-- DropForeignKey
ALTER TABLE "MonitoringResult" DROP CONSTRAINT "MonitoringResult_websiteId_fkey";

-- DropForeignKey
ALTER TABLE "NotificationConfig" DROP CONSTRAINT "NotificationConfig_userId_fkey";

-- DropForeignKey
ALTER TABLE "StakingRecord" DROP CONSTRAINT "StakingRecord_validatorNodeId_fkey";

-- DropForeignKey
ALTER TABLE "Subscription" DROP CONSTRAINT "Subscription_userId_fkey";

-- DropForeignKey
ALTER TABLE "ValidationReward" DROP CONSTRAINT "ValidationReward_userId_fkey";

-- DropForeignKey
ALTER TABLE "ValidationReward" DROP CONSTRAINT "ValidationReward_validatorNodeId_fkey";

-- DropForeignKey
ALTER TABLE "ValidatorNode" DROP CONSTRAINT "ValidatorNode_userId_fkey";

-- DropForeignKey
ALTER TABLE "Website" DROP CONSTRAINT "Website_userId_fkey";

-- DropIndex
DROP INDEX "User_email_key";

-- DropIndex
DROP INDEX "User_walletAddress_key";

-- AlterTable
ALTER TABLE "User" DROP COLUMN "createdAt",
DROP COLUMN "isEmailVerified",
DROP COLUMN "name",
DROP COLUMN "passwordHash",
DROP COLUMN "role",
DROP COLUMN "updatedAt",
DROP COLUMN "walletAddress";

-- AlterTable
ALTER TABLE "Website" DROP COLUMN "alertThreshold",
DROP COLUMN "checkInterval",
DROP COLUMN "createdAt",
DROP COLUMN "customHeaders",
DROP COLUMN "description",
DROP COLUMN "expectedStatus",
DROP COLUMN "isActive",
DROP COLUMN "name",
DROP COLUMN "updatedAt",
ADD COLUMN     "disabled" BOOLEAN NOT NULL DEFAULT false;

-- DropTable
DROP TABLE "Alert";

-- DropTable
DROP TABLE "ApiKey";

-- DropTable
DROP TABLE "ConsensusData";

-- DropTable
DROP TABLE "MonitoringCheck";

-- DropTable
DROP TABLE "MonitoringOptions";

-- DropTable
DROP TABLE "MonitoringResult";

-- DropTable
DROP TABLE "NotificationConfig";

-- DropTable
DROP TABLE "StakingRecord";

-- DropTable
DROP TABLE "Subscription";

-- DropTable
DROP TABLE "ValidationReward";

-- DropTable
DROP TABLE "ValidatorNode";

-- DropEnum
DROP TYPE "AlertStatus";

-- DropEnum
DROP TYPE "CheckStatus";

-- DropEnum
DROP TYPE "NodeStatus";

-- DropEnum
DROP TYPE "PaymentStatus";

-- DropEnum
DROP TYPE "RewardStatus";

-- DropEnum
DROP TYPE "StakingStatus";

-- DropEnum
DROP TYPE "SubscriptionPlan";

-- DropEnum
DROP TYPE "UserRole";

-- CreateTable
CREATE TABLE "Validator" (
    "id" TEXT NOT NULL,
    "publicKey" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "ip" TEXT NOT NULL,
    "pendingPayouts" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "Validator_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WebsiteTick" (
    "id" TEXT NOT NULL,
    "websiteId" TEXT NOT NULL,
    "validatorId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "status" "WebsiteStatus" NOT NULL,
    "latency" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "WebsiteTick_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "WebsiteTick" ADD CONSTRAINT "WebsiteTick_websiteId_fkey" FOREIGN KEY ("websiteId") REFERENCES "Website"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WebsiteTick" ADD CONSTRAINT "WebsiteTick_validatorId_fkey" FOREIGN KEY ("validatorId") REFERENCES "Validator"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
