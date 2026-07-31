import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { PaginationDto } from '../../common/dtos/pagination.dto';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';

@ApiTags('Notifications')
@Controller('api/v1/notifications')
@ApiBearerAuth()
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get notifications' })
  getNotifications(
    @GetCurrentUserId() userId: string,
    @Query() paginationDto: PaginationDto,
  ) {
    return this.notificationsService.getNotifications(userId, paginationDto);
  }

  @Patch(':id/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark notification as read' })
  markAsRead(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
  ) {
    return this.notificationsService.markAsRead(userId, id);
  }

  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllAsRead(@GetCurrentUserId() userId: string) {
    return this.notificationsService.markAllAsRead(userId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete notification' })
  deleteNotification(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
  ) {
    return this.notificationsService.deleteNotification(userId, id);
  }

  @Delete()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete all notifications' })
  deleteAllNotifications(@GetCurrentUserId() userId: string) {
    return this.notificationsService.deleteAllNotifications(userId);
  }
}
