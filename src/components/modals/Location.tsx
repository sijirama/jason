import { useState } from 'react';
import { useGeolocated } from 'react-geolocated';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '../ui/button';

const LocationModal = () => {
    const [isModalOpen, setIsModalOpen] = useState(true);
    const {
        coords,
        isGeolocationAvailable,
        isGeolocationEnabled,
        getPosition,
        positionError,
    } = useGeolocated({
        positionOptions: {
            enableHighAccuracy: true,
        },
        watchPosition: true,
        onError: (error) => {
            console.error('Geolocation Error:', error);
        },
    });

    const shouldShowModal = !isGeolocationAvailable || !isGeolocationEnabled || !coords;

    return (
        <Dialog open={isModalOpen && shouldShowModal} onOpenChange={setIsModalOpen}>
            <DialogContent className="bg-white rounded-lg shadow-lg w-full max-w-md px-6 py-8">
                <DialogHeader className="border-b border-gray-200 pb-4 mb-4">
                    <DialogTitle className="text-lg font-medium">Location Required</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                    {!isGeolocationAvailable ? (
                        <p>Your browser does not support Geolocation.</p>
                    ) : !isGeolocationEnabled ? (
                        <p>Geolocation is not enabled. Please enable it in your browser settings.</p>
                    ) : coords ? (
                        <>
                            <p>Your location has been set:</p>
                            <ul className="space-y-2">
                                <li>Latitude: {coords.latitude}</li>
                                <li>Longitude: {coords.longitude}</li>
                            </ul>
                        </>
                    ) : (
                        <p>Getting the location data&hellip;</p>
                    )}
                    {positionError && (
                        <p className="text-red-500 font-medium">Error: {positionError.message}</p>
                    )}
                </div>
                <div className="flex justify-end mt-6 space-x-2">
                    <Button onClick={() => getPosition()} variant="default">
                        Get Location Manually
                    </Button>
                    <Button onClick={() => setIsModalOpen(false)} variant="secondary">
                        Close
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
};

export default LocationModal;
