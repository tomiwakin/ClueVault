# ClueVault 🏆🔍  
*A Blockchain-Based Scavenger Hunt with Progressive Puzzles and Rewards*  

## Overview  
**ClueVault** is a decentralized scavenger hunt smart contract built on the Stacks blockchain. It allows players to solve cryptographic puzzles at different stages, with rewards for successful solutions. Each stage unlocks progressively as players solve clues, and winners are recorded on-chain for transparency.  

## Features  
- **Decentralized Gameplay**: Clues and solutions are managed securely on-chain.  
- **Progressive Challenges**: Each stage unlocks based on a predefined block height.  
- **Fair Competition**: Players must submit correct solutions to advance.  
- **On-Chain Rewards**: Prize pools are distributed to players who solve puzzles.  
- **Immutable History**: All player progress and stage solutions are stored on the blockchain.  

## Smart Contract Components  

### 🔹 Constants  
- **Error Codes**: Predefined error messages for incorrect actions.  
- **Entry Fee**: Cost to participate in the hunt (in STX).  
- **Admin Controls**: Only the contract admin can set up the hunt.  

### 🔹 Data Structures  
- **Hunt Stages**: Stores clues, encrypted solutions (hashes), unlock conditions, and rewards.  
- **Player Progress**: Tracks each player's current stage, solved stages, and attempt history.  
- **Stage Solutions**: Records solution attempts per player for each stage.  
- **Stage Winners**: Maintains a list of the top 10 winners per stage.  

### 🔹 Functions  

#### Hunt Management  
- **`initialize-hunt`** → Starts the hunt and resets game state.  
- **`add-stage`** → Adds a new stage with a clue, solution hash, unlock block, and prize.  

#### Player Registration  
- **`register-player`** → Registers a player after collecting the entry fee.  

#### Gameplay  
- **`submit-solution`** → Players submit their answers (hashed for verification). If correct, they advance to the next stage and receive rewards.  

#### Read-Only Functions  
- **`get-current-clue`** → Fetches the clue for an active stage.  
- **`get-player-status`** → Retrieves a player's progress in the hunt.  
- **`get-stage-winners`** → Lists winners for a specific stage.  
- **`get-hunt-stats`** → Displays overall game status and prize pool information.  

## How It Works  
1. **Admin initializes the hunt** and sets up different stages with encrypted solutions.  
2. **Players register** by paying an entry fee in STX.  
3. **Players solve puzzles** by submitting their hashed solutions.  
4. **Correct answers unlock the next stage** and distribute rewards.  
5. **Leaderboard is updated** with the fastest solvers per stage.  

## Security & Fairness  
- **Solutions are stored as hashes** to prevent tampering.  
- **Time-locked stages** ensure fair play by preventing early access.  
- **Transparent rewards** with on-chain prize distribution.  

## Future Enhancements  
- NFT-based achievements for top solvers.  
- Integration with off-chain puzzle validators.  
- Support for multi-chain scavenger hunts.  

## License  
This smart contract is open-source and licensed under [MIT License](LICENSE).  

---

🚀 **Are you ready to crack the ClueVault?** Let the hunt begin! 🔎💰