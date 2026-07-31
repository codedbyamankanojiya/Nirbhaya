import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateIncidentDto, UpdateIncidentDto } from './dto/incident.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { AuditLogAction, IncidentStatus, Role } from '@prisma/client';

@Injectable()
export class IncidentsService {
  private readonly logger = new Logger(IncidentsService.name);

  constructor(private prisma: PrismaService) {}

  async createIncident(userId: string, dto: CreateIncidentDto) {
    const { mediaIds, ...incidentData } = dto;

    const incident = await this.prisma.incident.create({
      data: {
        userId,
        ...incidentData,
        status: IncidentStatus.PENDING,
        uploadedMedia: mediaIds
          ? {
              connect: mediaIds.map((id) => ({ id })),
            }
          : undefined,
      },
      include: { uploadedMedia: true, user: { include: { profile: true } } },
    });

    await this.prisma.auditLog.create({
      data: {
        userId,
        action: AuditLogAction.INCIDENT_CREATE,
        metadata: { incidentId: incident.id },
      },
    });

    this.logger.log(`Incident created: ${incident.id}`);

    return incident;
  }

  async getMyIncidents(userId: string, paginationDto: PaginationDto) {
    const { page, limit, sortBy, sortOrder, search } = paginationDto;

    const skip = (page - 1) * limit;
    const where: any = { userId };

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [incidents, total] = await Promise.all([
      this.prisma.incident.findMany({
        where,
        include: { uploadedMedia: true },
        skip,
        take: limit,
        orderBy: sortBy ? { [sortBy]: sortOrder } : { createdAt: 'desc' },
      }),
      this.prisma.incident.count({ where }),
    ]);

    return {
      data: incidents,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAllIncidents(
    paginationDto: PaginationDto,
    status?: IncidentStatus,
    category?: string,
  ) {
    const { page, limit, sortBy, sortOrder, search } = paginationDto;

    const skip = (page - 1) * limit;
    const where: any = {};

    if (status) {
      where.status = status;
    }
    if (category) {
      where.category = category;
    }
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [incidents, total] = await Promise.all([
      this.prisma.incident.findMany({
        where,
        include: {
          uploadedMedia: true,
          user: {
            include: { profile: true },
          },
        },
        skip,
        take: limit,
        orderBy: sortBy ? { [sortBy]: sortOrder } : { createdAt: 'desc' },
      }),
      this.prisma.incident.count({ where }),
    ]);

    return {
      data: incidents,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getIncidentById(
    userId: string, incidentId: string, role: Role) {
    const incident = await this.prisma.incident.findUnique({
      where: { id: incidentId },
      include: { uploadedMedia: true, user: { include: { profile: true } } },
    });

    if (!incident) {
      throw new NotFoundException('Incident not found');
    }

    if (role !== Role.ADMIN && incident.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return incident;
  }

  async updateIncident(
    userId: string,
    incidentId: string,
    dto: UpdateIncidentDto,
    role: Role,
  ) {
    const incident = await this.prisma.incident.findUnique({
      where: { id: incidentId },
    });

    if (!incident) {
      throw new NotFoundException('Incident not found');
    }

    if (role !== Role.ADMIN && incident.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    const updateData: any = { ...dto };

    if (role !== Role.ADMIN) {
      delete updateData.status;
      delete updateData.adminNotes;
    }

    return this.prisma.incident.update({
      where: { id: incidentId },
      data: updateData,
      include: { uploadedMedia: true },
    });
  }

  async deleteIncident(userId: string, incidentId: string, role: Role) {
    const incident = await this.prisma.incident.findUnique({
      where: { id: incidentId },
    });

    if (!incident) {
      throw new NotFoundException('Incident not found');
    }

    if (role !== Role.ADMIN && incident.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    await this.prisma.incident.delete({
      where: { id: incidentId },
    });

    return { message: 'Incident deleted successfully' };
  }
}
