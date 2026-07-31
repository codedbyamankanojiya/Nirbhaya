import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateContactDto, UpdateContactDto } from './dto/contact.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';

@Injectable()
export class ContactsService {
  private readonly logger = new Logger(ContactsService.name);

  constructor(private prisma: PrismaService) {}

  async createContact(userId: string, dto: CreateContactDto) {
    const existingContact = await this.prisma.emergencyContact.findFirst({
      where: { userId, phone: dto.phone },
    });

    if (existingContact) {
      throw new ConflictException('Contact with this phone already exists');
    }

    if (dto.isPrimary) {
      await this.prisma.emergencyContact.updateMany({
        where: { userId, isPrimary: true },
        data: { isPrimary: false },
      });
    }

    const count = await this.prisma.emergencyContact.count({
      where: { userId },
    });

    if (count >= 10) {
      throw new ConflictException('Maximum 10 contacts allowed');
    }

    const contact = await this.prisma.emergencyContact.create({
      data: {
        userId,
        ...dto,
      },
    });

    this.logger.log(`Contact created: ${contact.id}`);

    return contact;
  }

  async getContacts(userId: string, paginationDto: PaginationDto) {
    const { page, limit, sortBy, sortOrder, search } = paginationDto;

    const skip = (page - 1) * limit;
    const where: any = { userId };

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [contacts, total] = await Promise.all([
      this.prisma.emergencyContact.findMany({
        where,
        skip,
        take: limit,
        orderBy: sortBy
          ? { [sortBy]: sortOrder }
          : { priority: 'asc', createdAt: 'desc' },
      }),
      this.prisma.emergencyContact.count({ where }),
    ]);

    return {
      data: contacts,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getContactById(userId: string, contactId: string) {
    const contact = await this.prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!contact) {
      throw new NotFoundException('Contact not found');
    }

    if (contact.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return contact;
  }

  async updateContact(
    userId: string,
    contactId: string,
    dto: UpdateContactDto,
  ) {
    const contact = await this.prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!contact) {
      throw new NotFoundException('Contact not found');
    }

    if (contact.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (dto.isPrimary) {
      await this.prisma.emergencyContact.updateMany({
        where: { userId, isPrimary: true, NOT: { id: contactId } },
        data: { isPrimary: false },
      });
    }

    if (dto.phone && dto.phone !== contact.phone) {
      const existingContact = await this.prisma.emergencyContact.findFirst({
        where: { userId, phone: dto.phone, NOT: { id: contactId } },
      });

      if (existingContact) {
        throw new ConflictException('Contact with this phone already exists');
      }
    }

    return this.prisma.emergencyContact.update({
      where: { id: contactId },
      data: dto,
    });
  }

  async deleteContact(userId: string, contactId: string) {
    const contact = await this.prisma.emergencyContact.findUnique({
      where: { id: contactId },
    });

    if (!contact) {
      throw new NotFoundException('Contact not found');
    }

    if (contact.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    await this.prisma.emergencyContact.delete({
      where: { id: contactId },
    });

    return { message: 'Contact deleted successfully' };
  }
}
