import Request from '../models/Request.js';

/**
 * Check if an equipment has overlapping approved rental requests for given date range
 */
export const checkRentalOverlap = async (equipmentId, startDate, endDate, excludeRequestId = null) => {
  const query = {
    equipment: equipmentId,
    status: 'approved',
    requestType: 'rental',
    $or: [
      // Condition 1: New start date falls within existing approved booking
      {
        rentalStartDate: { $lte: new Date(startDate) },
        rentalEndDate: { $gte: new Date(startDate) },
      },
      // Condition 2: New end date falls within existing approved booking
      {
        rentalStartDate: { $lte: new Date(endDate) },
        rentalEndDate: { $gte: new Date(endDate) },
      },
      // Condition 3: Existing booking falls entirely inside new requested range
      {
        rentalStartDate: { $gte: new Date(startDate) },
        rentalEndDate: { $lte: new Date(endDate) },
      },
    ],
  };

  if (excludeRequestId) {
    query._id = { $ne: excludeRequestId };
  }

  const conflicting = await Request.find(query);
  return conflicting;
};
