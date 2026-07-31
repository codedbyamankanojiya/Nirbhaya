import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ContactsService } from './contacts.service';
import { CreateContactDto, UpdateContactDto } from './dto/contact.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';

@ApiTags('Emergency Contacts')
@Controller('api/v1/contacts')
@ApiBearerAuth()
export class ContactsController {
  constructor(private contactsService: ContactsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create emergency contact' })
  createContact(
    @GetCurrentUserId() userId: string,
    @Body() dto: CreateContactDto,
  ) {
    return this.contactsService.createContact(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all emergency contacts' })
  getContacts(
    @GetCurrentUserId() userId: string,
    @Query() paginationDto: PaginationDto,
  ) {
    return this.contactsService.getContacts(userId, paginationDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get contact by ID' })
  getContactById(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
  ) {
    return this.contactsService.getContactById(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update emergency contact' })
  updateContact(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateContactDto,
  ) {
    return this.contactsService.updateContact(userId, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete emergency contact' })
  deleteContact(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
  ) {
    return this.contactsService.deleteContact(userId, id);
  }
}
