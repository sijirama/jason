
import React from 'react';
import { motion } from 'framer-motion';
import { Alert } from '@/types/alert';

export const AlertCard: React.FC<{ alert: Alert }> = ({ alert }) => (
    <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -50 }}
        className="bg-white rounded-lg shadow-md p-4 mb-4"
    >
        <h3 className="text-lg font-semibold mb-2">{alert.Title}</h3>
        <p className="text-sm text-gray-600 mb-2">{alert.Description}</p>
        <div className="flex justify-between items-center text-xs text-gray-500">
            <span>Status: {alert.CreatedAt.toString()}</span>
            <span>Urgency: {alert.Urgency}</span>
        </div>
    </motion.div>
);

