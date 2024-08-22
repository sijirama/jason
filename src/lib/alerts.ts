import { socket } from "./socket";


export const joinAlertRoom = (latitude: number, longitude: number, radius: number) => {
    if (!socket) return;
    console.log("Emitting 'join_alert_room' event");
    try {
        console.log(latitude.toString(), longitude.toString(), String(radius))
        socket.emit('join_alert_room', latitude.toString(), longitude.toString(), String(radius));
        console.log(`Joining alert room for coordinates: ${latitude}, ${longitude}`);
    } catch (err) {
        console.error("Failed to join alert room: ", err);
    }
};
