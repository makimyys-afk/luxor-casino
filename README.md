# Luxor Casino for OpenComputers

Luxor Casino is a visually appealing casino application designed for the **OpenComputers** mod in Minecraft 1.7.10. It offers three classic casino games, a PIM-like balance system, and a beautiful graphical user interface built with character-based graphics.

## ✨ Features

*   **Three Engaging Games**: Enjoy playing Slots, Roulette, and Blackjack.
*   **PIM Emulation**: Easily top up your in-game balance.
*   **Persistent Balance**: Your balance is saved between sessions, ensuring continuity.
*   **Stunning GUI**: Experience a colorful and intuitive interface using character graphics.

## 💻 Tech Stack

*   **Lua**: The programming language used for the application logic.
*   **OpenComputers API**: Utilizes the OpenComputers mod's API for interacting with in-game components like GPU and Screen.

## 📦 Installation & Setup

To run Luxor Casino, you need a computer set up with the OpenComputers mod in Minecraft 1.7.10, including a Tier 2+ GPU, a Screen, an Internet Card (for direct download), and an HDD with OpenOS.

### Method 1: Direct Download (Recommended)

In the OpenComputers console, execute the following command:

```lua
wget https://raw.githubusercontent.com/makimyys-afk/luxor-casino/main/main.lua /home/casino.lua && /home/casino.lua
```

### Method 2: Via Pastebin

1.  Copy the content of `main.lua` from the repository.
2.  Upload the content to [pastebin.com](https://pastebin.com).
3.  In the OpenComputers game, execute: `pastebin run <YOUR_PASTEBIN_CODE>`

## 🎮 Usage

Once the application is running, you can interact with it using the following controls:

*   **Left Mouse Button**: Click on buttons to make selections or play games.
*   **ESC Key**: Exit the application.

### Games Overview

*   **Slots (Bet: $10)**:
    *   Three identical symbols = big win
    *   Two identical symbols = 2x bet
*   **Roulette (Bet: $10)**:
    *   Choose RED or BLACK.
    *   Winning = 2x bet.
*   **Blackjack (Bet: $10)**:
    *   Simplified version.
    *   Get closer to 21 than the dealer to win.

## 📝 License

This project is licensed under the MIT License.