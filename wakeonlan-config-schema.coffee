module.exports = {
  title: "pimatic-wakeonlan config schema"
  type: "object"
  properties:
    broadcastAddress:
      description: "UDP broadcast address used to send WOL packet"
      type: "string"
      default: "255.255.255.255"
}