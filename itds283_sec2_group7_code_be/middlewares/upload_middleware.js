const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); 
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); 
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|webp|pdf/;

  const isValidExt = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const isValidMime = allowedTypes.test(file.mimetype);

  if (isValidExt && isValidMime) {
    return cb(null, true);
  } else {
    cb(new Error('อัปโหลดล้มเหลว: อนุญาตเฉพาะไฟล์รูปภาพ หรือ PDF เท่านั้น!'), false);
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024
  }
});

const uploadFields = upload.fields([
  { name: 'image', maxCount: 1 }, 
  { name: 'pdf', maxCount: 1 }    
]);

const handleUploadError = (req, res, next) => {
  uploadFields(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ message: `อัปโหลดล้มเหลว: ${err.message}` });
    } else if (err) {
      return res.status(400).json({ message: err.message });
    }

    next();
  });
};

module.exports = handleUploadError;