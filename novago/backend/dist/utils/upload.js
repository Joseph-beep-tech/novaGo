"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.upload = void 0;
exports.getFileUrl = getFileUrl;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
// Create uploads directories if they don't exist
const restaurantsDir = path_1.default.join(__dirname, '../../uploads/restaurants');
const menusDir = path_1.default.join(__dirname, '../../uploads/menus');
if (!fs_1.default.existsSync(restaurantsDir)) {
    fs_1.default.mkdirSync(restaurantsDir, { recursive: true });
}
if (!fs_1.default.existsSync(menusDir)) {
    fs_1.default.mkdirSync(menusDir, { recursive: true });
}
const uploadsDir = restaurantsDir;
// Configure storage
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        // Generate unique filename: timestamp-random-originalname
        const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1E9)}`;
        const ext = path_1.default.extname(file.originalname);
        const baseName = path_1.default.basename(file.originalname, ext);
        cb(null, `${baseName}-${uniqueSuffix}${ext}`);
    },
});
// File filter - allow images and videos
const fileFilter = (req, file, cb) => {
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
    }
    else {
        cb(new Error('Invalid file type. Only images and videos are allowed.'));
    }
};
// Multer configuration
exports.upload = (0, multer_1.default)({
    storage,
    fileFilter,
    limits: {
        fileSize: 50 * 1024 * 1024, // 50MB max file size
    },
});
// Helper to get file URL
function getFileUrl(filename) {
    return `/uploads/restaurants/${filename}`;
}
