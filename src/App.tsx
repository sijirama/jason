import { Button } from "./components/ui/button";
import { useInterface } from "./store/interface";
import { socket } from "./lib/socket";
import { useGeolocated } from "react-geolocated";
import { useEffect } from "react";
import { joinAlertRoom } from "./lib/alerts";
import { Alert } from "./types/alert";
import useAlertStore from "./store/alert";
import FloatingMenu from "./components/custom/FloatingMenu";

function App() {
    const { onOpen } = useInterface();
    const { coords } = useGeolocated();
    const { addAlert } = useAlertStore();

    useEffect(() => {
        // Ensure that socket connection is established
        socket.connect();

        // Add event listeners
        socket.on("connect", () => {
            console.log('Connected to socket server');
            if (coords) {
                joinAlertRoom(coords.latitude, coords.longitude, 1000);
            }
        });

        socket.on("alert", (data: Alert) => {
            //console.log("Received alert:", data);
            addAlert(data);
        });

        socket.on('disconnect', () => {
            console.log('Disconnected from socket server');
        });

        // Cleanup event listeners on unmount
        return () => {
            socket.off("connect");
            socket.off("alert");
            socket.off('disconnect');
            socket.disconnect();
            console.log('Socket disconnected');
        };
    }, [coords, addAlert]);

    // Handle joining the alert room whenever the coordinates change
    useEffect(() => {
        if (coords) {
            joinAlertRoom(coords.latitude, coords.longitude, 1000);
        }
    }, [coords]);

    return (
        <main className="font-poppins">
            <FloatingMenu />
            {socket.connected ? <Button>Connected {socket.id || "id"}</Button> : <Button>Disconnected</Button>}
            <Button onClick={() => onOpen("signInForm")}>Enter</Button>
        </main>
    );
}

export default App;

