# 🎵 Lavalink v4 - Railway Deployment

Lavalink audio streaming server untuk Discord music bots, siap deploy ke Railway dengan 1 click!

## ✨ Features

- ✅ Lavalink v4.0.8 (Latest stable)
- ✅ 24/7 uptime di Railway cloud
- ✅ YouTube, SoundCloud, Bandcamp, Twitch, Vimeo support
- ✅ Audio filters (Equalizer, Karaoke, Reverb, dll)
- ✅ Low-latency G1GC dengan 512MB RAM optimization
- ✅ Auto-restart on failure
- ✅ HTTPS/WSS support via Railway proxy

## 🚀 Quick Deploy ke Railway

### Step 1: Fork Repository (Optional)
```bash
Visit: https://github.com/riboncabe500-ctrl/publik/fork
```

### Step 2: Buka Railway
Visit: https://railway.app

### Step 3: Create New Project
1. Click "New Project"
2. Select "Deploy from GitHub"
3. Connect GitHub (jika belum)
4. Select repository: `riboncabe500-ctrl/publik` (atau fork Anda)
5. Select branch: `lavalink-v4-setup`
6. Click "Deploy"

### Step 4: Configure Environment Variables
Di Railway dashboard, set:
```
PORT = 8080
SERVER_PORT = 8080
LAVALINK_SERVER_PASSWORD = <GANTI_DENGAN_PASSWORD_KUAT>
LAVALINK_SERVER_SOURCES_YOUTUBE = true
LAVALINK_SERVER_SOURCES_SOUNDCLOUD = true
LAVALINK_SERVER_SOURCES_HTTP = true
```

### Step 5: Wait & Get Domain
Tunggu 5-10 menit, Railway akan assign domain seperti:
```
https://lavalink-prod-xyz.up.railway.app
```

## 📡 Connect Discord Bot

### Python (discord.py + wavelink)
```python
LAVALINK_NODES = [
    {
        "host": "your-railway-domain.up.railway.app",
        "port": 443,
        "password": "<YOUR_PASSWORD>",
        "identifier": "Railway-Production",
        "ssl": True,
        "secure": True
    }
]
```

### JavaScript (discord.js + shoukaku)
```javascript
const nodes = [
  {
    name: "Railway",
    url: "your-railway-domain.up.railway.app:443",
    auth: "<YOUR_PASSWORD>",
    secure: true,
    group: "default"
  }
];
```

## ✅ Test Connection

```bash
curl -H "Authorization: <YOUR_PASSWORD>" \
  https://your-railway-domain.up.railway.app/info
```

Expected response (HTTP 200):
```json
{
  "version": {"semver": "4.0.8"},
  "sources": ["youtube", "soundcloud", ...],
  "filters": ["equalizer", "karaoke", ...],
  "maxPlayers": 1000
}
```

## 📚 Documentation

- [Lavalink Official](https://lavalink.dev)
- [Wavelink (Python)](https://wavelink.dev)
- [Shoukaku (JavaScript)](https://github.com/Deivu/Shoukaku)
- [Railway Docs](https://docs.railway.app)

## 🔧 Local Development

### Using Docker Compose
```bash
docker-compose up -d
```

### Access Locally
```bash
curl -H "Authorization: youshallnotpass" \
  http://localhost:8080/info
```

## ⚙️ Configuration

Edit `application.yml` untuk customize:
- Port
- Audio sources
- Buffer size
- GC warnings
- Custom filters

## 🔐 Security

⚠️ **PENTING:**
1. Ganti `LAVALINK_SERVER_PASSWORD` dengan password kuat
2. Jangan share password Anda
3. Gunakan HTTPS (Railway handle ini otomatis)
4. Restrict bot access ke Lavalink endpoint

## 📊 Performance

- **Memory**: 512MB max (optimized untuk Railway free)
- **GC**: G1GC dengan low pause time untuk audio streaming
- **Uptime**: 24/7 dengan Railway (Pro plan) atau 3-hour sleep (Free plan)

## 🆘 Troubleshooting

### Build fails
- Check GitHub connection di Railway settings
- Ensure branch `lavalink-v4-setup` exists

### Container keeps restarting
- Check logs di Railway dashboard
- Verify environment variables
- Check password format

### Connection timeout
- Wait 5+ minutes untuk DNS propagate
- Check domain di Railway networking settings
- Verify HTTPS is enabled

## 📝 License

Lavalink: [Apache 2.0](https://github.com/lavalink-devs/Lavalink/blob/main/LICENSE)
This setup: MIT

## 👨‍💻 Credits

Setup oleh: [riboncabe500-ctrl](https://github.com/riboncabe500-ctrl)

Based on: [Lavalink](https://github.com/lavalink-devs/Lavalink)
