import multer from 'multer';
import path from 'path';
import { Request } from 'express';
import fs from 'fs';

// Create uploads directories if they don't exist
const restaurantsDir = path.join(__dirname, '../../uploads/restaurants');
const menusDir = path.join(__dirname, '../../uploads/menus');
if (!fs.existsSync(restaurantsDir)) {
  fs.mkdirSync(restaurantsDir, { recursive: true });
}
if (!fs.existsSync(menusDir)) {
  fs.mkdirSync(menusDir, { recursive: true });
}

const uploadsDir = restaurantsDir;

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: timestamp-random-originalname
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1E9)}`;
    const ext = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, ext);
    cb(null, `${baseName}-${uniqueSuffix}${ext}`);
  },
});

// File filter - allow images and videos
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedMimes = [
    // Images
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    // Videos
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/webm',
  ];

  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only images and videos are allowed.'));
  }
};

// Multer configuration
export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB max file size
  },
});

// Helper to get file URL
export function getFileUrl(filename: string): string {
  return `/uploads/restaurants/${filename}`;
}

