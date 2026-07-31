import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SosService } from './sos.service';
import { CreateSosDto, UpdateSosStatusDto } from './dto/sos.dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';
import { GetCurrentUser } from '../../decorators/get-current-user.decorator';
import { Roles } from '../../decorators/roles.decorator';
import { Role, SOSStatus } from '@prisma/client';

@ApiTags('SOS')
@Controller('api/v1/sos')
@ApiBearerAuth()
export class SosController {
  constructor(private sosService: SosService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Trigger SOS' })
  createSos(
    @GetCurrentUserId() userId: string,
    @Body() dto: CreateSosDto,
    @Request() req: any,
  ) {
    return this.sosService.createSos(
      userId,
      dto,
      req.ip,
      req.headers['user-agent'],
    );
  }

  @Get('history')
  @ApiOperation({ summary: 'Get user SOS history' })
  getSosHistory(
    @GetCurrentUserId() userId: string,
    @Query() paginationDto: PaginationDto,
  ) {
    return this.sosService.getSosHistory(userId, paginationDto);
  }

  @Get('all')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get all SOS requests (Admin only)' })
  getAllSos(
    @Query() paginationDto: PaginationDto,
    @Query('status') status?: SOSStatus,
  ) {
    return this.sosService.getAllSos(paginationDto, status);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get SOS by ID' })
  getSosById(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @GetCurrentUser('role') role: Role,
  ) {
    return this.sosService.getSosById(userId, id, role);
  }

  @Patch(':id/status')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Update SOS status (Admin only)' })
  updateSosStatus(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateSosStatusDto,
  ) {
    return this.sosService.updateSosStatus(userId, id, dto);
  }
}
