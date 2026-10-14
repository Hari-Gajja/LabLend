import { Router } from 'express';
import * as uploadController from '../controllers/uploadController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/signature', uploadController.getSignature);
router.delete('/:publicId', uploadController.deleteAsset);

export default router;
