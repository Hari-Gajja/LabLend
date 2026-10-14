import { Router } from 'express';
import * as institutionController from '../controllers/institutionController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.get('/', institutionController.listInstitutions);
router.get('/me', authenticate, institutionController.getMyInstitution);
router.patch('/me', authenticate, institutionController.updateMyInstitution);
router.get('/:id', institutionController.getInstitutionById);

export default router;
