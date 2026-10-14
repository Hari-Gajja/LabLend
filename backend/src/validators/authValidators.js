import { z } from 'zod';

export const registerSchema = z.object({
  fullName: z.string().min(2, 'Full name must be at least 2 characters').max(100),
  email: z.string().email('Please enter a valid institutional email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  institutionName: z.string().min(2, 'Institution name must be at least 2 characters'),
  institutionType: z.enum(['university', 'college', 'research_institute', 'hospital', 'commercial_lab', 'other']).default('university'),
  city: z.string().min(2, 'City is required'),
  state: z.string().min(2, 'State or province is required'),
  contactNumber: z.string().optional().default(''),
  department: z.string().optional().default(''),
  title: z.string().optional().default('Researcher'),
});

export const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
});

export const resetPasswordSchema = z.object({
  token: z.string().min(1, 'Reset token is required'),
  newPassword: z.string().min(8, 'Password must be at least 8 characters'),
});
