# 🔒 FiveM Admin Jail System

A configurable **Admin Jail system for FiveM** designed for moderation and roleplay scenarios, with persistent jail time tracking and staff-controlled enforcement.

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

## ✨ Features

* 🔒 **Forced Player Jailing** – Staff can instantly jail players into a restricted area
* ⛓️ **Movement Restriction** – Prevents players from escaping or bypassing jail
* ⏱️ **Persistent Jail Time** – Time is saved in the database and only decreases while the player is online
* 🎭 **RP & Moderation Use** – Ideal for perma-death scenarios or admin “timeouts”
* 👨‍💼 **Permission-Based Access** – Only authorized staff groups can use the system
* 🔔 **ox_lib Notifications** – Clean and modern in-game alerts
* 📊 **Version Checker** – Automatically checks GitHub for updates

## 📦 Dependencies

* [es_extended](https://github.com/esx-framework/esx_core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)

## 🛠 Installation

1. Download the latest release
2. Extract it into your `resources` folder
3. Rename the folder to your desired resource name
4. Add the resource to your `server.cfg`:

```cfg
ensure your-resource-name
```

5. Configure `config.lua` to fit your server needs
6. Restart your server

> The database table is created automatically on first start.

## ⚙️ Configuration

### Basic Setup

Edit `config.lua` to configure jail settings:

```lua
Config.JailLocation = vector3(0.0, 0.0, 0.0) -- Jail coordinates
Config.JailRadius = 10.0 -- Area players are restricted to

Config.StaffGroups = {
    'admin',
    'superadmin'
}

Config.DefaultJailTime = 600 -- Time in seconds
```

### Optional Settings

```lua
Config.AllowCommandsInJail = false -- Disable commands while jailed
Config.ReleaseOnDisconnect = false -- Keep jail time saved if player leaves
```

## ⌨️ Commands

### Staff Commands

* `/jail [id] [time]` – Jail a player for a set duration
* `/unjail [id]` – Release a player from jail
* `/jailtime [id]` – Check remaining jail time

> Commands require appropriate staff permissions.
> Adjust permission checks in `server/main.lua` if needed.

## 🗄 Database

The script automatically creates the following table:

```sql
CREATE TABLE IF NOT EXISTS admin_jail (
    identifier VARCHAR(60) PRIMARY KEY,
    jail_time INT NOT NULL
);
```

### How It Works

* Jail time is stored per player
* Time only decreases while the player is connected
* Players who disconnect will retain their remaining sentence

### Manual Reset (if needed)

```sql
DELETE FROM admin_jail;
```

## 🧩 Support

* Open an issue on GitHub for bugs or suggestions
* Please check existing issues before creating a new one

## 📄 License

This project is licensed under the **GPL License**.

## ❤️ Credits

* Built with **ox_lib**
* Database handled via **oxmysql**
* Compatible with **ESX Framework**

## 📷 Screenshots

<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/8c067dd0-bef4-491c-940f-4c38d65464a4" />
