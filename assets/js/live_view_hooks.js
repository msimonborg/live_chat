const Hooks = {}
const localTz =
  Intl.DateTimeFormat().resolvedOptions().timeZone

Hooks.ChatRoom = {
  mounted() {
    this.pushEvent("local_timezone", { local_timezone: localTz })
  },
  reconnected() {
    this.pushEvent("local_timezone", { local_timezone: localTz })
  }
}
export default Hooks