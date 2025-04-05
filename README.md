# 🚀 ES-AURAHUD | Premium FiveM Vehicle & Status HUD

[![YouTube Subscribe](https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube)](https://www.youtu.be/iKb6hdepiBg)
[![Discord](https://img.shields.io/badge/Discord-Join-blue?style=for-the-badge&logo=discord)](https://discord.gg/EkwWvFS)
[![Tebex Store](https://img.shields.io/badge/Tebex-Store-green?style=for-the-badge&logo=shopify)](https://eyestore.tebex.io/)

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Framework](https://img.shields.io/badge/Framework-ESX%20%7C%20QBCore-orange.svg)

![image](https://github.com/user-attachments/assets/479b45ec-6dee-476b-8248-7405379750c8)


## 📋 Overview

**ES-AURAHUD** is an advanced HUD system for FiveM servers that delivers a sleek, modern interface for both vehicle data and character status tracking. Designed with performance optimization in mind, this resource enhances player immersion while maintaining high FPS.

Perfect for roleplay servers looking to provide a premium UI experience with comprehensive status tracking and vehicle information.

## ✨ Key Features

- **🔄 Multi-Framework Compatibility** - Full support for ESX, NewESX, and QBCore frameworks
- **🏎️ Dynamic Vehicle HUD** - Real-time speedometer, RPM gauge, fuel level, and gear indicators
- **🔋 Nitrous System Integration** - Built-in nitro functionality with visual effects and item usage
- **📊 Comprehensive Status Tracking** - Monitor health, armor, hunger, thirst, stress, and oxygen
- **🎨 Modern UI Design** - Elegant interface with smooth animations and transitions
- **📱 Responsive Layout** - Adapts perfectly to all screen resolutions
- **⚡ Performance Optimized** - Minimal resource usage with maximum visual impact
- **🛠️ Highly Configurable** - Easy to customize through config files
- **💰 Job & Money Display** - Real-time job information and cash balance

## 🖼️ Screenshots

<div style="display: flex; justify-content: space-between;">
    <img src="https://via.placeholder.com/400x225?text=Vehicle+HUD" alt="Vehicle HUD" width="400"/>
    <img src="https://via.placeholder.com/400x225?text=Status+Display" alt="Status Display" width="400"/>
</div>
<div style="display: flex; justify-content: space-between; margin-top: 10px;">
    <img src="https://via.placeholder.com/400x225?text=Nitro+System" alt="Nitro System" width="400"/>
    <img src="https://via.placeholder.com/400x225?text=Job+Information" alt="Job Information" width="400"/>
</div>

## 📋 Technical Details

- **Framework Detection:** Automatic detection of ESX, NewESX, or QBCore
- **Server-Side Optimization:** Efficient callback system for player data
- **Stress Management:** Complete stress system with whitelisted jobs
- **Nitro System:** Server-side item validation and synchronization
- **Event-Based Architecture:** Clean code structure with event-driven updates

## ⚙️ Installation

1. **Download the resource** from the [releases page](https://github.com/yourusername/es-aurahud/releases)
2. **Extract the files** to your server's resources folder
3. **Configure** the `main/shared.lua` file to match your server's needs
4. **Add** `ensure es-aurahud` to your server.cfg
5. **Restart** your server and enjoy your new HUD!

## 🔧 Configuration

```lua
-- Example configuration
Config = {}
Config.Framework = 'QBCore' -- QBCore, ESX, NewESX, OLDQBCore
Config.Refresh = 'HudRefresh'
Config.NitroItem = "nitrous" -- Item to install nitro
Config.NitroControl = "G" -- Key to activate nitro
Config.SeatbeltControl = 'k' -- Seatbelt toggle key
```

## 📚 Documentation

For full documentation, including all configuration options and API references, please visit our [Wiki](https://github.com/yourusername/es-aurahud/wiki).

## 🔄 Compatibility

ES-AURAHUD has been tested and confirmed working with:

- ✅ ESX Framework (Legacy)
- ✅ ESX Framework (New)
- ✅ QBCore Framework
- ✅ OLDQBCore Framework
- ✅ Most popular inventory systems
- ✅ Custom job systems

## 🛠️ Development & Contribution

Contributions are welcome! If you'd like to improve ES-AURAHUD:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 🆘 Support

For support, issues, or feature requests:
- Create an [Issue](https://github.com/raiderss/es-aurahud/issues)
- Join our [Discord](https://discord.gg/EkwWvFS)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🔗 Links

- [FiveM Forum](https://forum.cfx.re)
- [Author's GitHub](https://github.com/yourusername)
- [Discord Community](https://discord.gg/EkwWvFS)

## 🏆 Credits

Developed with ❤️ by [Raider#0101](https://github.com/yourusername)

---

### Keywords
FiveM, HUD, ESX, QBCore, GTARP, roleplay, speedometer, vehicle HUD, status bars, nitro system, stress system, responsive UI, gaming UI, server resource, player status
