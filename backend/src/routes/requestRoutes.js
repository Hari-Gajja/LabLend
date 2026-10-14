import { Router } from 'express';
import * as requestController from '../controllers/requestController.js';
import { authenticate } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import {
  createRequestSchema,
  approveRequestSchema,
  rejectRequestSchema,
  cancelRequestSchema,
  completeRequestSchema,
} from '../validators/requestValidators.js';

const router = Router();

// All request routes require authentication
router.use(authenticate);

router.post('/', validate(createRequestSchema), requestController.createRequest);
router.get('/sent', requestController.getSentRequests);
router.get('/received', requestController.getReceivedRequests);
router.get('/:id', requestController.getRequestById);
router.patch('/:id/approve', validate(approveRequestSchema), requestController.approveRequest);
router.patch('/:id/reject', validate(rejectRequestSchema), requestController.rejectRequest);
router.patch('/:id/cancel', validate(cancelRequestSchema), requestController.cancelRequest);
router.patch('/:id/complete', validate(completeRequestSchema), requestController.completeRequest);

export default router;
