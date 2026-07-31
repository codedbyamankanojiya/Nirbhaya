import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../database/prisma.service';
import { v2 as cloudinary } from 'cloudinary';

@Injectable()
export class UploadsService {
  private readonly logger = new Logger(UploadsService.name);

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    cloudinary.config({
      cloud_name: this.configService.get<string>('cloudinary.cloudName'),
      api_key: this.configService.get<string>('cloudinary.apiKey'),
      api_secret: this.configService.get<string>('cloudinary.apiSecret'),
    });
  }

  async uploadFile(userId: string, file: Express.Multer.File) {
    const maxSize = 10 * 1024 * 1024;

    if (!file) {
      throw new BadRequestException('No file provided');
    }

    if (file.size > maxSize) {
      throw new BadRequestException('File size exceeds 10MB');
    }

    const allowedTypes = ['image/', 'video/', 'audio/'];
    const isValidType = allowedTypes.some((type) => file.mimetype.startsWith(type));

    if (!isValidType) {
      throw new BadRequestException('Invalid file type');
    }

    try {
      const result = await new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            resource_type: 'auto',
            folder: 'nirbhaya/uploads',
          },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          },
        );
        uploadStream.end(file.buffer);
      });

      const media = await this.prisma.uploadedMedia.create({
        data: {
          userId,
          url: (result as any).secure_url,
          publicId: (result as any).public_id,
          type: file.mimetype,
          size: file.size,
        },
      });

      this.logger.log(`File uploaded: ${media.id}`);

      return media;
    } catch (error) {
      this.logger.error('Upload failed', error);
      throw new BadRequestException('Failed to upload file');
    }
  }

  async deleteFile(userId: string, mediaId: string) {
    const media = await this.prisma.uploadedMedia.findUnique({
      where: { id: mediaId },
    });

    if (!media) {
      throw new BadRequestException('Media not found');
    }

    if (media.userId !== userId) {
      throw new BadRequestException('Access denied');
    }

    try {
      await cloudinary.uploader.destroy(media.publicId);
      await this.prisma.uploadedMedia.delete({ where: { id: mediaId } });

      return { message: 'File deleted successfully' };
    } catch (error) {
      this.logger.error('Delete failed', error);
      throw new BadRequestException('Failed to delete file');
    }
  }

  async getFiles(userId: string) {
    return this.prisma.uploadedMedia.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
