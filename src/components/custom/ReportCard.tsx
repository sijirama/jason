import { useEffect, useState } from 'react';
import { AiOutlineWarning } from 'react-icons/ai';
import { FiMapPin, FiClock } from 'react-icons/fi';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Skeleton } from '../ui/skeleton';

interface ReportCardProps {
    id?: string;
    open?: boolean;
}

export default function ReportCard({ id }: ReportCardProps) {
    const [alert, setAlert] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (id) {
            fetchAlertData(id);
        }
    }, [id]);

    const fetchAlertData = async (alertId: string) => {
        try {
            const response = await fetch(`/api/alerts/${alertId}`);
            const data = await response.json();
            setAlert(data.alert);
        } catch (error) {
            console.error('Error fetching alert data:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <Card>
                <CardHeader>
                    <Skeleton className="w-full h-8" />
                </CardHeader>
                <CardContent>
                    <Skeleton className="w-full h-6 mb-2" />
                    <Skeleton className="w-full h-6" />
                </CardContent>
            </Card>
        );
    }

    if (!alert) {
        return (
            <Card>
                <CardContent className="text-center">
                    <p>No alert found</p>
                </CardContent>
            </Card>
        );
    }

    return (
        <Card>
            <CardHeader>
                <div className="flex items-center space-x-2">
                    <AiOutlineWarning className="text-red-600 text-xl" />
                    <CardTitle>{alert.title}</CardTitle>
                </div>
                <CardDescription className="flex items-center space-x-1 mt-1">
                    <FiMapPin className="text-gray-500" />
                    <span>{alert.location}</span>
                </CardDescription>
            </CardHeader>
            <CardContent>
                <div className="flex items-center space-x-2">
                    <FiClock className="text-gray-500" />
                    <span>{new Date(alert.createdAt).toLocaleString()}</span>
                </div>
                <p className="mt-4">{alert.description}</p>
            </CardContent>
        </Card>
    );
}

