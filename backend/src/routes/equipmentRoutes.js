import { Router } from 'express';
import * as equipmentController from '../controllers/equipmentController.js';
import { authenticate, optionalAuth } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import {
  createEquipmentSchema,
  updateEquipmentSchema,
  queryEquipmentSchema,
  updateAvailabilitySchema,
} from '../validators/equipmentValidators.js';

const router = Router();

router.get('/', validate(queryEquipmentSchema, 'query'), equipmentController.listEquipment);
router.get('/mine', authenticate, equipmentController.getMyEquipment);
router.post('/', authenticate, validate(createEquipmentSchema), equipmentController.createEquipment);
router.get('/:id', optionalAuth, equipmentController.getEquipmentById);
router.patch('/:id', authenticate, validate(updateEquipmentSchema), equipmentController.updateEquipment);
router.delete('/:id', authenticate, equipmentController.deleteEquipment);
router.patch(
  '/:id/availability',
  authenticate,
  validate(updateAvailabilitySchema),
  equipmentController.updateAvailability
);

export default router;
