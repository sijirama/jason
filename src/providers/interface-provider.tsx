import { useEffect, useState } from "react";

import SignUpForm from "@/components/modals/SignIn"
import LocationModal from "@/components/modals/Location";
import AlertSheet from "@/components/modals/alertsSheet";

export function InterfaceProvider() {
    const [isMounted, setIsMounted] = useState(false);

    useEffect(() => {
        setIsMounted(true);
    }, []);

    if (!isMounted) {
        return null;
    }

    return (
        <>
            <SignUpForm />
            <LocationModal />
            <AlertSheet />
        </>
    );
}
