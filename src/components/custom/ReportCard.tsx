import React, { useEffect, useState, useCallback } from 'react';
import { AlertTriangle, MapPin, Clock, AlertCircle, ThumbsUp, Flag, CheckCircle, Loader2 } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Alert } from '@/types/alert';
import moment from 'moment';
import useIsAuthenticated from 'react-auth-kit/hooks/useIsAuthenticated';

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
    const [isVerifying, setIsVerifying] = useState(false);
    const [isResolving, setIsResolving] = useState(false);
    const [isFlagging, setIsFlagging] = useState(false);
    const isAuthenticated = useIsAuthenticated();

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

    const handleVerify = async () => {
        if (id) {
            setIsVerifying(true);
            try {
                // Optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Verifications: [...(prevAlert?.Verifications || []), { id: 'temp' }]
                }));

                // API call
                await fetch(`/api/alert/${id}/verify`, { method: 'POST' });

                // Refresh data
                await fetchAlert();
            } catch (error) {
                console.error('Error verifying alert:', error);
                // Revert optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Verifications: prevAlert?.Verifications.filter(v => v.id !== 'temp') || []
                }));
            } finally {
                setIsVerifying(false);
            }
        }
    };

    const handleResolve = async () => {
        if (id) {
            setIsResolving(true);
            try {
                // Optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Status: 'Resolved'
                }));

                // API call
                await fetch(`/api/alert/${id}/resolve`, { method: 'POST' });

                // Refresh data
                await fetchAlert();
            } catch (error) {
                console.error('Error resolving alert:', error);
                // Revert optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Status: 'Active'
                }));
            } finally {
                setIsResolving(false);
            }
        }
    };

    const handleFlagAsFalse = async () => {
        if (id) {
            setIsFlagging(true);
            try {
                // Optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Status: 'Flagged as False'
                }));

                // API call
                await fetch(`/api/alert/${id}/flag-false`, { method: 'POST' });

                // Refresh data
                await fetchAlert();
            } catch (error) {
                console.error('Error flagging alert as false:', error);
                // Revert optimistic update
                setAlert(prevAlert => ({
                    ...prevAlert!,
                    Status: 'Active'
                }));
            } finally {
                setIsFlagging(false);
            }
        }
    };

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
        <div className="p-4">
            <div className="mb-3">
                <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-2">
                        <AlertTriangle className={`${urgencyColor} text-xl`} />
                        <h2 className="text-lg font-bold text-gray-800">{alert.Title}</h2>
                    </div>
                    <Badge variant="outline" className={`${urgencyColor} border-current`}>
                        Urgency: {alert.Urgency}/10
                    </Badge>
                </div>
                <p className="flex items-center space-x-1 text-sm text-gray-600">
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
                    <Badge variant="secondary">{alert.Status}</Badge>
                </div>
            </div>

            {isAuthenticated && (
                <div className="mt-4 flex justify-between">
                    <Button
                        onClick={handleVerify}
                        disabled={isVerifying}
                        className="bg-blue-500 hover:bg-blue-600 text-white"
                    >
                        {isVerifying ? (
                            <Loader2 className="w-4 h-4 animate-spin" />
                        ) : (
                            <ThumbsUp className="w-4 h-4" />
                        )}
                        <span className="ml-2">Verify</span>
                    </Button>
                    <Button
                        onClick={handleResolve}
                        disabled={isResolving}
                        className="bg-green-500 hover:bg-green-600 text-white"
                    >
                        {isResolving ? (
                            <Loader2 className="w-4 h-4 animate-spin" />
                        ) : (
                            <CheckCircle className="w-4 h-4" />
                        )}
                        <span className="ml-2">Resolve</span>
                    </Button>
                    <Button
                        onClick={handleFlagAsFalse}
                        disabled={isFlagging}
                        className="bg-red-500 hover:bg-red-600 text-white"
                    >
                        {isFlagging ? (
                            <Loader2 className="w-4 h-4 animate-spin" />
                        ) : (
                            <Flag className="w-4 h-4" />
                        )}
                        <span className="ml-2">Flag as False</span>
                    </Button>
                </div>
            )}
        </div>
    );
});

export default ReportCard;
