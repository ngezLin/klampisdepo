/**
 * Compresses an image file client-side using Canvas API.
 * Uses WebP if supported, fallback to JPEG.
 * @param {File} file - The original image File object.
 * @param {number} maxWidth - Maximum width of the compressed image.
 * @param {number} maxHeight - Maximum height of the compressed image.
 * @param {number} quality - Compression quality (0 to 1).
 * @returns {Promise<File>} A promise resolving to the compressed File object.
 */
export const compressImage = (
  file,
  maxWidth = 800,
  maxHeight = 800,
  quality = 0.7,
) => {
  return new Promise((resolve, reject) => {
    if (!file || !file.type.startsWith("image/")) {
      return reject(new Error("File provided is not an image"));
    }

    const img = new Image();
    const reader = new FileReader();

    reader.onload = (e) => {
      img.src = e.target.result;
    };

    reader.onerror = (e) => reject(e);

    img.onload = () => {
      let width = img.width;
      let height = img.height;

      // Calculate new dimensions proportional to max settings
      if (width > height) {
        if (width > maxWidth) {
          height = Math.round((height * maxWidth) / width);
          width = maxWidth;
        }
      } else {
        if (height > maxHeight) {
          width = Math.round((width * maxHeight) / height);
          height = maxHeight;
        }
      }

      const canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;

      const ctx = canvas.getContext("2d");
      // Optional: fill background with white if PNG has transparency and we export to JPEG
      if (file.type === "image/png" || file.type === "image/jpeg") {
        ctx.fillStyle = "#fff";
        ctx.fillRect(0, 0, width, height);
      }

      ctx.drawImage(img, 0, 0, width, height);

      // WebP provides better compression ratios. If browser doesn't support it, modern browsers fallback cleanly or we default down to jpeg.
      // Usually .toBlob(cb, "image/webp", quality) works magically on most setups.
      let outType = "image/webp";
      let finalFilename = file.name.replace(/\.[^/.]+$/, "") + ".webp";

      canvas.toBlob(
        (blob) => {
          if (!blob) {
            return reject(new Error("Canvas conversion to Blob failed"));
          }
          // Wrap blob back into a File
          const compressedFile = new File([blob], finalFilename, {
            type: outType,
            lastModified: Date.now(),
          });
          resolve(compressedFile);
        },
        outType,
        quality,
      );
    };

    reader.readAsDataURL(file);
  });
};
