# FocusReward

A blockchain-based productivity incentive system that rewards users for completing focused activities.

## Overview

FocusReward is a decentralized application that helps users improve productivity by providing token incentives for completing focused work sessions. The system tracks user activity, rewards consistency, and allows users to lock up tokens for additional benefits.

## Features

- **Activity Tracking**: Track focused work sessions with customizable timeframes
- **Incentive System**: Earn tokens for completing focused activities
- **Consistency Bonuses**: Build streaks by doing activities daily to earn increased rewards
- **Token Economy**: Redeem earned tokens for benefits within the ecosystem
- **Token Lockup**: Lock tokens to earn additional benefits with time-based multipliers
- **Transparent Statistics**: View your progress and platform-wide metrics on the blockchain

## Smart Contract Structure

### Core Components

- **Activity Management**: Begin and finish focused work sessions
- **Incentive Distribution**: Automatically distribute tokens for completed activities
- **Consistency Tracking**: Monitor and reward daily activity streaks
- **Token Lockup**: Lock and unlock tokens with time-based incentives

### Key Data Structures

- User activities and incentive balances
- Activity streaks and consistency levels
- Token lockup amounts and durations
- Platform-wide statistics

## Usage

### Starting a Focused Activity

```clarity
(begin-activity u30)  ;; Start a 30-block activity session
```

### Completing an Activity

```clarity
(finish-activity u30)  ;; Complete the activity after at least 30 blocks
```

### Redeeming Incentives

```clarity
(redeem-incentives)  ;; Redeem all available incentive tokens
```

### Locking Tokens

```clarity
(lock-tokens u100)  ;; Lock 100 tokens for future benefits
```

### Unlocking Tokens

```clarity
(unlock-tokens)  ;; Unlock all locked tokens (fees may apply for early withdrawals)
```

## Technical Details

### Constants

- Maximum token pool: 1,000,000 tokens
- Base incentive per activity: 10 tokens
- Consistency bonus: 2 tokens per streak level (up to 7 levels)
- Minimum lockup period: 288 blocks (approximately 2 days)
- Early withdrawal fee: 10%

### Read-Only Functions

- `get-activity-count`: View number of activities completed by a user
- `get-incentive-balance`: Check available incentive balance
- `get-user-consistency`: View current consistency streak level
- `get-platform-stats`: Get platform-wide statistics

## Development

### Prerequisites

- Clarity development environment
- Stacks blockchain wallet
- Basic understanding of blockchain concepts

### Installation

1. Clone the repository
2. Install dependencies
3. Deploy on the Stacks blockchain

## Security

- The contract includes safeguards against common vulnerabilities
- Early withdrawal fees protect against token supply manipulation
- Activity validation prevents fraudulent reward claims
