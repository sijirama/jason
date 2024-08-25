import { useEffect, useState } from "react";

import SignInForm from "@/components/modals/SignIn"
import AlertSheet from "@/components/modals/alertsSheet";
import ReportAlert from "@/components/modals/ReportAlert";
import ReportCardModal from "@/components/modals/ReportCardModal";
import SignUpFormModal from "@/components/modals/SignUp";

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
            <SignInForm />
            <SignUpFormModal />
            <AlertSheet />
            <ReportAlert />
            <ReportCardModal />
        </>
    );
}
