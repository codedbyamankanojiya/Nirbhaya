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
import { IncidentsService } from './incidents.service';
import { CreateIncidentDto, UpdateIncidentDto } from './dto/incident.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';
import { GetCurrentUser } from '../../decorators/get-current-user.decorator';
import { Roles } from '../../decorators/roles.decorator';
import { IncidentStatus, Role } from '@prisma/client';

@ApiTags('Incidents')
@Controller('api/v1/incidents')
@ApiBearerAuth()
export class IncidentsController {
  constructor(private incidentsService: IncidentsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create incident report' })
  createIncident(
    @GetCurrentUserId() userId: string,
    @Body() dto: CreateIncidentDto,
  ) {
    return this.incidentsService.createIncident(userId, dto);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get my incidents' })
  getMyIncidents(
    @GetCurrentUserId() userId: string,
    @Query() paginationDto: PaginationDto,
  ) {
    return this.incidentsService.getMyIncidents(userId, paginationDto);
  }

  @Get('all')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get all incidents (Admin only)' })
  getAllIncidents(
    @Query() paginationDto: PaginationDto,
    @Query('status') status?: IncidentStatus,
    @Query('category') category?: string,
  ) {
    return this.incidentsService.getAllIncidents(paginationDto, status, category);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get incident by ID' })
  getIncidentById(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @GetCurrentUser('role') role: Role,
  ) {
    return this.incidentsService.getIncidentById(userId, id, role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update incident' })
  updateIncident(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateIncidentDto,
    @GetCurrentUser('role') role: Role,
  ) {
    return this.incidentsService.updateIncident(userId, id, dto, role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete incident' })
  deleteIncident(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @GetCurrentUser('role') role: Role,
  ) {
    return this.incidentsService.deleteIncident(userId, id, role);
  }
}
