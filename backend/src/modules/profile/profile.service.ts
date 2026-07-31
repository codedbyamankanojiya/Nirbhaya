import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { UpdateProfileDto } from './dto/profile.dto';
import { AuditLogAction } from '@prisma/client';

@Injectable()
export class ProfileService {
  private readonly logger = new Logger(ProfileService.name);

  constructor(private prisma: PrismaService) {}

  async getProfile(userId: string) {
    const profile = await this.prisma.profile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Profile not found');
    }

    return profile;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const profile = await this.prisma.profile.upsert({
      where: { userId },
      update: { ...dto },
      create: {
        userId,
        name: dto.name || user.email.split('@')[0],
        ...dto,
      },
    });

    await this.prisma.auditLog.create({
      data: {
        userId,
        action: AuditLogAction.PROFILE_UPDATE,
      },
    });

    this.logger.log(`Profile updated for user: ${userId}`);

    return profile;
  }

  async deleteProfile(userId: string) {
    await this.prisma.profile.delete({
      where: { userId },
    });

    return { message: 'Profile deleted successfully' };
  }
}
