import Map, { Marker } from 'react-map-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

import { useLocationStore } from '@/store/location';
import useAlertStore from '@/store/alert';

import useAuthUser from 'react-auth-kit/hooks/useAuthUser';
import { avatarImageUrl } from '@/lib/avatar';
import { User } from '@/types';
import { socket } from '@/lib/socket';
import { useMemo } from 'react';

const MapBoxSiji = "mapbox://styles/sijiramakun/cm04mgec700ej01qtc1ekexg4"

export default function MapComponent() {
    const { coords } = useLocationStore();
    const { alerts } = useAlertStore()
    const auth = useAuthUser();


    const alertsMarkers = useMemo(() => alerts.map((alert) => {
        return (
            <Marker key={alert.ID} latitude={alert.Location.Latitude} longitude={alert.Location.Longitude}>
                <div className="bg-red-500 p-2 rounded-full text-white">
                    {alert.Title}
                </div>
            </Marker>

        )
    }), [alerts])

    if (!coords?.longitude || !coords.latitude) {
        return null
    }

    return (
        <section className='w-full h-full'>
            <Map
                reuseMaps={true}
                mapboxAccessToken={import.meta.env.VITE_MAPBOX_KEY}
                initialViewState={{
                    longitude: coords?.longitude,
                    latitude: coords?.latitude,
                    zoom: 15
                }}
                //onClick={handleMapClick}
                style={{ width: "100%", height: "100vh" }}
                mapStyle={MapBoxSiji}
            >
                {alertsMarkers}
                {
                    <Marker latitude={coords.latitude} longitude={coords.longitude}>
                        {
                            auth ? (
                                <div
                                    className={`cursor-pointer rounded-full w-8 h-8 md:w-10 md:h-10 bg-center bg-cover bg-no-repeat border ${socket.connected
                                        ? 'border-green-500 border-2'
                                        : 'border-purple-300'
                                        }`}
                                    style={{
                                        backgroundImage: `url(${avatarImageUrl(auth as User)})`,
                                    }}
                                    aria-label="User menu"
                                />

                            ) : (
                                <div className="bg-red-500 p-2 rounded-full text-white">
                                    here
                                </div>
                            )
                        }
                    </Marker>
                }

            </Map>
        </section>
    )
}

