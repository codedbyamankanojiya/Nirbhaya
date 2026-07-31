import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateSosDto, UpdateSosStatusDto } from './dto/sos.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { AuditLogAction, Role, SOSStatus } from '@prisma/client';

@Injectable()
export class SosService {
  private readonly logger = new Logger(SosService.name);

  constructor(private prisma: PrismaService) {}

  async createSos(
    userId: string,
    dto: CreateSosDto,
    ipAddress?: string,
    userAgent?: string,
  ) {
    const sos = await this.prisma.sOS.create({
      data: {
        userId,
        latitude: dto.latitude,
        longitude: dto.longitude,
        description: dto.description,
        ipAddress,
        userAgent,
        status: SOSStatus.ACTIVE,
      },
      include: { user: { include: { profile: true, emergencyContacts: true } } },
    });

    await this.prisma.auditLog.create({
      data: {
        userId,
        action: AuditLogAction.SOS_TRIGGER,
        metadata: { sosId: sos.id },
      },
    });

    this.logger.warn(`SOS triggered by user: ${userId}`);

    return sos;
  }

  async getSosHistory(userId: string, paginationDto: PaginationDto) {
    const { page, limit, sortBy, sortOrder } = paginationDto;

    const skip = (page - 1) * limit;

    const [sosRequests, total] = await Promise.all([
      this.prisma.sOS.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: sortBy
          ? { [sortBy]: sortOrder }
          : { createdAt: 'desc' },
      }),
      this.prisma.sOS.count({ where: { userId } }),
    ]);

    return {
      data: sosRequests,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAllSos(
    paginationDto: PaginationDto,
    status?: SOSStatus,
  ) {
    const { page, limit, sortBy, sortOrder } = paginationDto;

    const skip = (page - 1) * limit;
    const where: any = {};

    if (status) {
      where.status = status;
    }

    const [sosRequests, total] = await Promise.all([
      this.prisma.sOS.findMany({
        where,
        include: { user: { include: { profile: true } } },
        skip,
        take: limit,
        orderBy: sortBy
          ? { [sortBy]: sortOrder }
          : { createdAt: 'desc' },
      }),
      this.prisma.sOS.count({ where }),
    ]);

    return {
      data: sosRequests,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getSosById(userId: string, sosId: string, role: Role) {
    const sos = await this.prisma.sOS.findUnique({
      where: { id: sosId },
      include: { user: { include: { profile: true, emergencyContacts: true } } },
    });

    if (!sos) {
      throw new NotFoundException('SOS not found');
    }

    if (role !== Role.ADMIN && sos.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return sos;
  }

  async updateSosStatus(
    userId: string,
    sosId: string,
    dto: UpdateSosStatusDto,
  ) {
    const sos = await this.prisma.sOS.findUnique({
      where: { id: sosId },
    });

    if (!sos) {
      throw new NotFoundException('SOS not found');
    }

    const updateData: any = { status: dto.status };
    if (dto.status === SOSStatus.RESOLVED || dto.status === SOSStatus.FALSE_ALARM) {
      updateData.resolvedAt = new Date();
      updateData.resolvedBy = userId;
    }

    return this.prisma.sOS.update({
      where: { id: sosId },
      data: updateData,
    });
  }
}
