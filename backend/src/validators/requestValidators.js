import { z } from 'zod';

export const createRequestSchema = z.object({
  equipmentId: z.string().min(1, 'Equipment ID is required'),
  requestType: z.enum(['rental', 'purchase']),
  requestedQuantity: z.number().int().min(1, 'Quantity must be at least 1').default(1),
  rentalStartDate: z.string().optional().nullable(),
  rentalEndDate: z.string().optional().nullable(),
  intendedUse: z.string().min(10, 'Please describe your research or intended use (minimum 10 characters)').max(1500),
  message: z.string().max(2000).optional().default(''),
}).refine(
  (data) => {
    if (data.requestType === 'rental') {
      if (!data.rentalStartDate || !data.rentalEndDate) {
        return false;
      }
      const start = new Date(data.rentalStartDate);
      const end = new Date(data.rentalEndDate);
      return !isNaN(start.getTime()) && !isNaN(end.getTime()) && end > start;
    }
    return true;
  },
  {
    message: 'Rental requests require valid start and end dates with end date after start date',
    path: ['rentalEndDate'],
  }
);

export const approveRequestSchema = z.object({
  notes: z.string().max(1000).optional().default(''),
});

export const rejectRequestSchema = z.object({
  reason: z.string().min(3, 'Please provide a reason for rejection').max(1000),
});

export const cancelRequestSchema = z.object({
  reason: z.string().max(1000).optional().default(''),
});

export const completeRequestSchema = z.object({
  notes: z.string().max(1000).optional().default(''),
});
