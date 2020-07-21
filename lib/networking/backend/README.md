# I-MIC FPS / CyberarmEngine Networking System
End Goal: Reliable and ordered packets of abitrary size

Current Goal: Unreliable, unordered packets of limited size

## Internal Packet Format
Based on [minetest's network protocol](https://dev.minetest.net/Network_Protocol)
### Base header
All packet headers start with these fields
```
Protocol Version: Unsigned char
Packet Type: Unsigned char
Peer ID: Unsigned char
```

### Basic packet header
No unique header fields

### Control packet header
```
Control Type: Unsigned char
Control Data: Unsigned 16-bit integer
```
Control Types:
* ACK - Acknowledge receipt of reliable packet
* SET_PEER_ID - Set peer id of connected client, client must provide this to continue communicating
* PING - Used to track peer's network latency
* HEARTBEAT - Used as keep alive
* DISCONNECT - Peer is disconnecting

### Split Packet Header
```
Sequence Number: Unsigned 16-bit number
Chunk Count: Unsigned 16-bit number
Chunk Number: Unsigned 16-bit number
```

### Reliable Packet Header
```
Sequence Number: Unsigned 16-bit number
```