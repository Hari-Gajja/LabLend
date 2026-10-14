import { z } from 'zod';

const imageItemSchema = z.object({
  url: z.string().url('Image URL must be a valid URL'),
  publicId: z.string().min(1, 'Cloudinary public ID is required'),
  isCover: z.boolean().optional().default(false),
});

const technicalSpecItemSchema = z.object({
  key: z.string().min(1, 'Specification name is required'),
  value: z.string().min(1, 'Specification value is required'),
});

const baseEquipmentSchema = z.object({
  title: z.string().min(3, 'Title must be at least 3 characters').max(180),
  description: z.string().min(10, 'Description must be at least 10 characters').max(4000),
  category: z.enum([
    'microscopy',
    'spectroscopy',
    'centrifugation',
    'chromatography',
    'thermal_analysis',
    'electronics',
    'cell_culture',
    'analytical_chemistry',
    'general_lab',
  ]),
  condition: z.enum(['like_new', 'excellent', 'good', 'fair']),
  listingType: z.enum(['rent', 'buy', 'both']),
  rentalPrice: z.number().nonnegative('Rental price must be >= 0').optional().nullable(),
  rentalPricingUnit: z.enum(['hour', 'day', 'week', 'month']).optional().default('day'),
  purchasePrice: z.number().nonnegative('Purchase price must be >= 0').optional().nullable(),
  availability: z.enum(['available', 'rented', 'maintenance', 'reserved']).optional().default('available'),
  location: z.object({
    building: z.string().optional().default(''),
    room: z.string().optional().default(''),
    city: z.string().min(1, 'City is required'),
    state: z.string().min(1, 'State is required'),
  }),
  images: z.array(imageItemSchema).min(1, 'At least one equipment image is required'),
  technicalSpecs: z.array(technicalSpecItemSchema).optional().default([]),
  featured: z.boolean().optional().default(false),
});

export const createEquipmentSchema = baseEquipmentSchema.refine(
  (data) => {
    if (data.listingType === 'rent' || data.listingType === 'both') {
      return data.rentalPrice !== undefined && data.rentalPrice !== null && data.rentalPrice > 0;
    }
    return true;
  },
  {
    message: 'Rental price is required when listing type is rent or both',
    path: ['rentalPrice'],
  }
).refine(
  (data) => {
    if (data.listingType === 'buy' || data.listingType === 'both') {
      return data.purchasePrice !== undefined && data.purchasePrice !== null && data.purchasePrice > 0;
    }
    return true;
  },
  {
    message: 'Purchase price is required when listing type is buy or both',
    path: ['purchasePrice'],
  }
);

export const updateEquipmentSchema = baseEquipmentSchema.partial();

export const queryEquipmentSchema = z.object({
  search: z.string().optional(),
  category: z.string().optional(),
  condition: z.string().optional(),
  listingType: z.enum(['rent', 'buy', 'both']).optional(),
  availability: z.enum(['available', 'rented', 'maintenance', 'reserved']).optional(),
  minPrice: z.coerce.number().nonnegative().optional(),
  maxPrice: z.coerce.number().nonnegative().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  sort: z.enum(['newest', 'price_asc', 'price_desc', 'popular']).optional().default('newest'),
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(12),
  featured: z.coerce.boolean().optional(),
});

export const updateAvailabilitySchema = z.object({
  availability: z.enum(['available', 'rented', 'maintenance', 'reserved']),
});
