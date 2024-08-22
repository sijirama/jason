import { useEffect, useState } from "react";

import SignUpForm from "@/components/modals/SignIn"
import AlertSheet from "@/components/modals/alertsSheet";
import ReportAlert from "@/components/modals/ReportAlert";

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
            <AlertSheet />
            <ReportAlert />
        </>
    );
}
