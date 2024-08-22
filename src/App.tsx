import { socket } from "./lib/socket";
import { useGeolocated } from "react-geolocated";
import { useEffect } from "react";
import { joinAlertRoom } from "./lib/alerts";
import { Alert } from "./types/alert";
import useAlertStore from "./store/alert";
import FloatingMenu from "./components/custom/FloatingMenu";
import MapComponent from "./components/custom/Map";

function App() {
    const { coords } = useGeolocated();
    const { addAlert } = useAlertStore();

    useEffect(() => {
        socket.connect();
        socket.on("connect", () => {
            console.log('Connected to socket server');
            if (coords) {
                joinAlertRoom(coords.latitude, coords.longitude, 1000);
            }
        });
        socket.on("alert", (data: Alert) => {
            addAlert(data);
        });
        socket.on('disconnect', () => {
            console.log('Disconnected from socket server');
        });
        return () => {
            socket.off("connect");
            socket.off("alert");
            socket.off('disconnect');
            socket.disconnect();
            console.log('Socket disconnected');
        };
    }, [coords, addAlert]);

    useEffect(() => {
        if (coords) {
            joinAlertRoom(coords.latitude, coords.longitude, 1000);
        }
    }, [coords]);

    return (
        <main className="font-poppins">
            <FloatingMenu />
            <MapComponent />
         </main>
    );
}

export default App;

