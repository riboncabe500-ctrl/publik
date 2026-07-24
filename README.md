# Lavalink v4 - Audio Streaming Server untuk Discord

> Implementasi production-ready dari **Lavalink v4** dengan optimasi untuk deployment di **Railway**.

## 📋 Daftar Isi

- [Apa itu Lavalink?](#apa-itu-lavalink)
- [Fitur Utama](#fitur-utama)
- [Prasyarat](#prasyarat)
- [Deployment ke Railway](#deployment-ke-railway)
- [Konfigurasi](#konfigurasi)
- [Usage & Connection](#usage--connection)
- [Architecture & Design Decisions](#architecture--design-decisions)
- [Troubleshooting](#troubleshooting)

---

## 🎵 Apa itu Lavalink?

**Lavalink** adalah audio streaming server yang dirancang khusus untuk bot Discord. Bertindak sebagai **media abstraction layer** yang:

- **Mengabstraksi multiple audio sources** (YouTube, SoundCloud, Spotify, Twitch, Bandcamp, dll)
- **Mendistribusikan load processing** audio ke multiple instances
- **Menyediakan WebSocket API** untuk komunikasi real-time dengan bot Discord
- **Optimasi latency rendah** untuk playback smooth tanpa lag

### Mengapa Lavalink?

```
┌─────────────────────────────────────────────────┐
│          Discord Bot (discord.py, discord.js)    │
└──────────────────┬──────────────────────────────┘
                   │ WebSocket Connection
                   │
┌──────────────────▼──────────────────────────────┐
│         Lavalink Audio Server (v4)              │
│  ┌────────────────────────────────────────────┐ │
│  │  YouTube │ SoundCloud │ Spotify │ Twitch   │ │
│  └────────────────────────────────────────────┘ │
└──────────────────┬──────────────────────────────┘
                   │ Audio Stream
                   │
        ┌──────────▼──────────┐
        │   Discord Servers   │
        │   (Penguna dengar)   │
        └──────────────��──────┘
```

---

## ✨ Fitur Utama

### Audio Sources
- ✅ **YouTube** - Full support (dengan search)
- ✅ **SoundCloud** - Full support
- ✅ **Spotify** - Track info & redirection
- ✅ **Twitch** - Stream support
- ✅ **Bandcamp** - Full support
- ✅ **Vimeo** - Full support
- ✅ **HTTP/HTTPS** - Direct links
- ✅ **Local Files** - Server-side files

### Audio Filters
Lavalink v4 supports advanced audio processing:
- **Equalizer** - 15-band equalizer
- **Karaoke** - Remove vocals
- **Tremolo** - Amplitude variation
- **Vibrato** - Pitch variation
- **Distortion** - Effect processing
- **Rotation** - 3D panning
- **Channel Mix** - Stereo manipulation
- **Low Pass** - Frequency filtering
- **Echo/Reverb/Delay** - Spatial effects
- **Compression** - Dynamic range control

### Performance Optimizations
- **G1 Garbage Collector** - Minimal pause times untuk streaming smooth
- **Memory-efficient** - Xmx512M heap allocation optimal untuk Railway
- **Connection pooling** - WebSocket reuse untuk efficiency
- **Buffer management** - 400ms buffer untuk stability

---

## 🔧 Prasyarat

1. **GitHub Account** - Repository ini
2. **Railway Account** - https://railway.app (free tier tersedia)
3. **Docker** - Untuk local testing (opsional)
4. **Discord Bot Token** - Untuk bot yang akan connect ke Lavalink

---

## 🚀 Deployment ke Railway

### Step 1: Deploy dari GitHub

```bash
# 1. Login ke Railway: https://railway.app
# 2. Klik "New Project"
# 3. Pilih "Deploy from GitHub repo"
# 4. Connect & select: riboncabe500-ctrl/publik
# 5. Pilih branch: lavalink-v4-setup
```

### Step 2: Configure Environment Variables

Di Railway dashboard, set variables berikut:

```yaml
LAVALINK_PASSWORD: <GANTI_DENGAN_PASSWORD_KUAT>
SERVER_PORT: 443
LAVALINK_SERVER_SOURCES_YOUTUBE: true
LAVALINK_SERVER_SOURCES_SOUNDCLOUD: true
LAVALINK_SERVER_SOURCES_HTTP: true
```

### Step 3: Deploy

Railway akan otomatis:
1. ✅ Build Docker image
2. ✅ Provision SSL/TLS certificate
3. ✅ Deploy container
4. ✅ Assign domain public (contoh: `lavalink-prod.up.railway.app`)

### Step 4: Test Connection

```bash
curl -H "Authorization: youshallnotpass" \
  https://lavalink-prod.up.railway.app/info
```

**Expected Response:**
```json
{
  "version": {
    "semver": "4.0.8",
    "major": 4,
    "minor": 0,
    "patch": 8
  },
  "buildLine": 1234,
  "git": {
    "branch": "main",
    "commit": "abc1234",
    "commitTime": 1234567890
  },
  "jvm": "17.0.1",
  "lavaplayer": "1.4.0.4",
  "filters": ["equalizer", "karaoke", "timescale", "tremolo", ...],
  "plugins": [...],
  "sources": ["youtube", "soundcloud", "bandcamp", ...],
  "sourceManagers": [...],
  "maxPlayers": 1000,
  "maxMemory": 537395200,
  "reservedMemory": 0,
  "usedMemory": 123456789,
  "freeMemory": 413938411,
  "allocatedMemory": 537395200,
  "processCpuUsage": 0.015,
  "systemCpuUsage": 0.25,
  "systemCpuLoadAverage": 0.5,
  "uptime": 3600000,
  "cpuCores": 2
}
```

---

## 🎛️ Konfigurasi

### application.yml - Core Settings

```yaml
# Server
server:
  port: 443                    # HTTPS port
  address: 0.0.0.0            # Listen all interfaces

# Lavalink
lavalink:
  server:
    password: ${LAVALINK_SERVER_PASSWORD}  # Auth password
    sources:
      youtube: true            # Enable/disable sources
      soundcloud: true
      http: true
    filters:
      volume: true             # Available audio filters
      equalizer: true
      karaoke: true
      # ... more filters

  # WebSocket Config
  ws:
    numWorkers: 1              # For Railway free tier
    bufferSize: 102400         # 100KB buffer
```

### Environment Variables (.env)

| Variable | Default | Purpose |
|----------|---------|---------|
| `LAVALINK_PASSWORD` | `youshallnotpass` | Server authentication |
| `SERVER_PORT` | `443` | HTTPS port |
| `LAVALINK_SERVER_SOURCES_*` | `true` | Enable/disable audio sources |
| `_JAVA_OPTIONS` | `-Xmx512M -Xms256M ...` | JVM memory & GC tuning |
| `SSL_KEYSTORE_PASSWORD` | `changeme` | SSL certificate password |

---

## 💻 Usage & Connection

### Connection dari Discord Bot

#### Python (discord.py + lavalink.py)

```python
import discord
from discord.ext import commands
import lavalink

class Music(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        
        # Lavalink node configuration
        lavalink.NodePool.get_node().set_server(
            host="your-railway-domain.up.railway.app",
            port=443,
            password="your_lavalink_password",
            ssl=True,  # HTTPS/WSS
            identifier="Production"
        )
    
    @commands.command()
    async def play(self, ctx, *, query):
        player = lavalink.get_player(ctx.guild.id)
        results = await player.node.get_tracks(query)
        
        if results['loadType'] == 'TRACK_LOADED':
            track = results['tracks'][0]
            player.queue.append(track)
            await player.play()

async def setup(bot):
    await bot.add_cog(Music(bot))
```

#### JavaScript (discord.js + lavalink)

```javascript
const Shoukaku = require('shoukaku');
const { Server } = require('discord.js');

const nodes = [
  {
    name: "Production",
    url: "your-railway-domain.up.railway.app:443",
    auth: "your_lavalink_password",
    secure: true,  // WSS
    group: "default"
  }
];

const shoukaku = new Shoukaku(client, nodes);

shoukaku.on('ready', () => {
  console.log('Lavalink connected!');
});
```

### REST API Endpoints

#### Get Server Info
```bash
curl -H "Authorization: youshallnotpass" \
  https://your-domain:443/info
```

#### Load Tracks
```bash
curl -H "Authorization: youshallnotpass" \
  "https://your-domain:443/loadtracks?identifier=ytsearch:hello%20world"
```

#### Decode Track
```bash
curl -X POST \
  -H "Authorization: youshallnotpass" \
  -H "Content-Type: application/json" \
  -d '{"track":"base64_encoded_track"}' \
  https://your-domain:443/decodetracks
```

---

## 🏗️ Architecture & Design Decisions

### Multi-stage Docker Build

```dockerfile
# Stage 1: Builder
FROM eclipse-temurin:17-jdk-alpine
# Download Lavalink.jar
RUN curl -L "https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar" \
    -o Lavalink.jar

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
# Copy hanya JAR, tidak ada JDK
COPY --from=builder /lavalink/Lavalink.jar .
```

**Rationale:**
- JDK size: ~400MB, JRE size: ~150MB
- Image final: ~200MB vs ~600MB
- Reduce attack surface (hanya runtime, no dev tools)

### Java Memory Configuration

```
_JAVA_OPTIONS="-Xmx512M -Xms256M -XX:+UseG1GC ..."
```

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `-Xmx512M` | Max heap | Railway free tier limit |
| `-Xms256M` | Min heap | Allocate upfront untuk stability |
| `G1GC` | Garbage Collector | Low-latency GC untuk audio |
| `-XX:MaxGCPauseMillis=200` | GC target | <200ms pause = smooth playback |

### SSL/TLS on Port 443

**Railway Behavior:**
- Auto-provision Let's Encrypt certificates
- HTTPS traffic → HTTP internally (port 443 externally, HTTP internally)
- WebSocket upgrade: `ws://` → `wss://`

**Configuration:**
```yaml
server:
  ssl:
    enabled: true
    key-store: /lavalink/data/keystore.p12
```

### WebSocket & Persistence

- **WebSocket Pool:** 1 worker (Railway free tier)
- **Buffer Size:** 102.4KB
- **Reconnect:** Automatic di aplikasi client
- **Session Timeout:** ~30 detik inactivity

---

## 🔍 Troubleshooting

### 1. Connection Refused (Port 443)

**Problem:** Bot tidak bisa connect ke Lavalink
```
Error: ECONNREFUSED 127.0.0.1:443
```

**Solution:**
```bash
# Check if Lavalink is running
curl -v https://your-domain:443/info

# Verify password is correct
curl -H "Authorization: your_password" \
  https://your-domain:443/info
```

### 2. SSL Certificate Error

**Problem:** `SSL_ERROR_BAD_CERT_DOMAIN`

**Solution:**
- Railway auto-assigns domain, gunakan domain itu (bukan IP)
- Certificate mungkin belum refresh, tunggu 5 menit

```bash
# Check certificate
openssl s_client -connect your-domain:443 -servername your-domain
```

### 3. Memory Pressure / Crash

**Problem:** Container restart terus menerus

**Solution:**
```bash
# Check logs di Railway dashboard
# Jika OOM (Out of Memory):
# - Reduce bufferDurationMs: 200 (dari 400)
# - Disable unused sources
# - Upgrade Railway plan

# Di application.yml:
lavalink:
  server:
    bufferDurationMs: 200  # <-- kurangi
```

### 4. No Audio / Silent

**Problem:** Track loading tapi tidak ada suara

**Solution:**
1. Verify track is loadable:
```bash
curl -H "Authorization: password" \
  "https://domain:443/loadtracks?identifier=ytsearch:test"
```

2. Check filters tidak semua muted
3. Client volume tidak 0

### 5. High CPU Usage

**Problem:** CPU usage >80%

**Solution:**
- Reduce concurrent players: `maxPlayers: 50` (dari unlimited)
- Disable expensive filters: distortion, echo, reverb
- Enable source limiting: `youtubePlaylistLoadLimit: 6`

---

## 📊 Monitoring & Health

### Health Check Endpoint

Railway automatically check:
```bash
# TCP health check every 30s
curl http://localhost:443/info
```

### Metrics via Actuator

```bash
curl -H "Authorization: password" \
  https://domain:443/actuator/metrics/jvm.memory.used
```

### Log Rotation

Logs auto-rotate di `/lavalink/logs/`:
- Max size: 10MB per file
- Max history: 30 files (~300MB total)

---

## 🔐 Security Best Practices

1. **Change Default Password**
   ```bash
   LAVALINK_PASSWORD=<generate_secure_password>
   ```

2. **Use HTTPS Only**
   - WSS (WebSocket Secure) mandatory untuk production
   - Port 443 hanya untuk HTTPS

3. **Restrict Audio Sources**
   ```yaml
   sources:
     youtube: true
     soundcloud: false  # Jika tidak perlu
     local: false       # Jika tidak perlu
   ```

4. **Monitor Resource Usage**
   - Railway dashboard → Metrics tab
   - Set alerts untuk high CPU/memory

5. **Regular Updates**
   - Check Lavalink releases: https://github.com/lavalink-devs/Lavalink/releases
   - Update Dockerfile dengan versi terbaru

---

## 📚 Referensi & Resources

- **Lavalink GitHub:** https://github.com/lavalink-devs/Lavalink
- **Lavalink Docs:** https://lavalink.dev/
- **Railway Docs:** https://docs.railway.app/
- **Discord.py Lavalink:** https://wavelink.dev/
- **Discord.js Lavalink:** https://github.com/Deivu/Shoukaku

---

## 📝 License

Repository ini adalah public implementation dari Lavalink v4.

Untuk lisensi Lavalink, referensikan: https://github.com/lavalink-devs/Lavalink/blob/main/LICENSE

---

**Last Updated:** 2026-07-24  
**Maintainer:** @riboncabe500-ctrl  
**Status:** ✅ Production Ready
