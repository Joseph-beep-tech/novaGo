# File Upload Examples for Restaurants

## 📝 How to Test Restaurant Creation with File Upload

### Using Postman

#### Method 1: With File Upload (Multipart Form-Data)

1. **Set Request Type:**
   - Method: `POST`
   - URL: `http://localhost:4000/api/restaurants`
   - Body tab: Select **"form-data"**

2. **Add Form Fields:**
   - `name`: `pale fruits` (Text)
   - `description`: `fresh fruits` (Text)
   - `cuisine`: `Fast Food` (Text)
   - `deliveryFee`: `2.99` (Text)
   - `deliveryTimeMinutesMin`: `15` (Text)
   - `deliveryTimeMinutesMax`: `25` (Text)
   - `address`: `456 Food Street` (Text)
   - `image`: Select **"File"** from dropdown, then choose an image/video file

3. **Click Send**

#### Method 2: JSON Body Only (No File Upload)

1. **Set Request Type:**
   - Method: `POST`
   - URL: `http://localhost:4000/api/restaurants`
   - Body tab: Select **"raw"** → **"JSON"**

2. **Add JSON Body:**
```json
{
  "name": "pale fruits",
  "description": "fresh fruits",
  "cuisine": "Fast Food",
  "deliveryFee": 2.99,
  "deliveryTimeMinutesMin": 15,
  "deliveryTimeMinutesMax": 25,
  "address": "456 Food Street"
}
```

3. **Click Send**

---

### Using cURL (Command Line)

#### With File Upload

```bash
curl -X POST http://localhost:4000/api/restaurants \
  -F "name=pale fruits" \
  -F "description=fresh fruits" \
  -F "cuisine=Fast Food" \
  -F "deliveryFee=2.99" \
  -F "deliveryTimeMinutesMin=15" \
  -F "deliveryTimeMinutesMax=25" \
  -F "address=456 Food Street" \
  -F "image=@/path/to/your/image.jpg"
```

#### JSON Body Only

```bash
curl -X POST http://localhost:4000/api/restaurants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "pale fruits",
    "description": "fresh fruits",
    "cuisine": "Fast Food",
    "deliveryFee": 2.99,
    "deliveryTimeMinutesMin": 15,
    "deliveryTimeMinutesMax": 25,
    "address": "456 Food Street"
  }'
```

---

## ✅ What Happens

1. **With File Upload:**
   - File is saved to `backend/uploads/restaurants/` directory
   - File gets unique name: `originalname-timestamp-random.ext`
   - Image URL is automatically set: `http://localhost:4000/uploads/restaurants/filename.ext`
   - Restaurant is created with the uploaded image URL

2. **Without File Upload:**
   - Restaurant is created with default placeholder image
   - Or you can provide `imageUrl` in JSON body

---

## 🔍 Verify Upload

After creating a restaurant with file upload:

1. Check the response - it should include `imageUrl`:
```json
{
  "id": "pale-fruits",
  "name": "pale fruits",
  "imageUrl": "http://localhost:4000/uploads/restaurants/image-1234567890-987654321.jpg",
  ...
}
```

2. Test the image URL in browser:
```
http://localhost:4000/uploads/restaurants/image-1234567890-987654321.jpg
```

3. Check the file on disk:
```
backend/uploads/restaurants/image-1234567890-987654321.jpg
```

---

## 📋 Supported File Types

- **Images:** JPEG, JPG, PNG, GIF, WEBP
- **Videos:** MP4, MPEG, QuickTime (.mov), AVI, WEBM
- **Max Size:** 50MB per file

---

## 🚨 Error Handling

If you get an error:
- **"Invalid file type"** - File is not an allowed image/video format
- **"File too large"** - File exceeds 50MB limit
- **"Invalid payload"** - Missing required fields or wrong data types

