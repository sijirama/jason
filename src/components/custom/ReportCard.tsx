import React, { useEffect, useState, useCallback } from 'react';
import { AlertTriangle, MapPin, Clock, AlertCircle, ThumbsUp, MessageSquare } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
import { Alert } from '@/types/alert';
import moment from 'moment';

interface ReportCardProps {
    id?: number;
    open?: boolean;
}

const fetchAlertData = async (alertId: number): Promise<Alert | null> => {
    try {
        const response = await fetch(`/api/alert/${alertId}`);
        const data = await response.json();
        return data.alert;
    } catch (error) {
        console.error('Error fetching alert data:', error);
        return null;
    }
};

const ReportCard = React.memo(({ id }: ReportCardProps) => {
    const [alert, setAlert] = useState<Alert | null>(null);
    const [loading, setLoading] = useState(true);

    const fetchAlert = useCallback(async () => {
        if (id) {
            setLoading(true);
            const data = await fetchAlertData(id);
            setAlert(data);
            setLoading(false);
        }
    }, [id]);

    useEffect(() => {
        fetchAlert();
    }, [fetchAlert]);

    if (loading) {
        return (
            <div className="p-4">
                <Skeleton className="w-full h-6 mb-2" />
                <Skeleton className="w-3/4 h-4 mb-2" />
                <Skeleton className="w-full h-20" />
            </div>
        );
    }

    if (!alert) {
        return (
            <div className="p-4 text-center">
                <AlertCircle className="mx-auto mb-2 text-gray-400" size={32} />
                <p className="text-gray-600">No alert found</p>
            </div>
        );
    }

    const urgencyColor = alert.Urgency > 7 ? "text-red-600" : alert.Urgency > 4 ? "text-orange-500" : "text-yellow-500";
    const formattedDate = moment(alert.CreatedAt).format('Do [of] MMM [around] h:mm A');

    return (
        <div className="p-4 font-poppins">
            <div className="mb-3">
                <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-2">
                        <AlertTriangle className={`${urgencyColor} text-xl`} />
                        <h2 className="text-lg font-bold tracking-tight text-gray-800">{alert.Title}</h2>
                    </div>
                    <Badge variant="outline" className={`${urgencyColor} text-xs border-current`}>
                        Urgency: {alert.Urgency}/10
                    </Badge>
                </div>
                <p className="flex items-center space-x-1 text-xs text-gray-600">
                    <MapPin className="w-4 h-4" />
                    <span>{alert.Location.Latitude.toFixed(4)}, {alert.Location.Longitude.toFixed(4)}</span>
                </p>
            </div>

            <div className="mb-4">
                <p className="flex items-center space-x-2 text-sm text-gray-500 mb-2">
                    <Clock className="w-4 h-4" />
                    <span>Reported {formattedDate}</span>
                </p>
                <p className="text-gray-700">{alert.Description}</p>
            </div>

            <div className="flex items-center justify-between text-sm text-gray-500 border-t border-gray-200 pt-3">
                <div className="flex items-center space-x-2">
                    <ThumbsUp className="w-4 h-4" />
                    <span>{alert.Verifications?.length || 0} Verifications</span>
                </div>
                <div className="flex items-center space-x-2">
                    <MessageSquare className="w-4 h-4" />
                    <span>{alert.Comments?.length || 0} Comments</span>
                </div>
            </div>
        </div>
    );
});

export default ReportCard;
