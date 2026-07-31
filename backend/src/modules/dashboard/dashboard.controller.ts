import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';
import { Roles } from '../../decorators/roles.decorator';
import { Role } from '@prisma/client';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';

@ApiTags('Dashboard')
@Controller('api/v1/dashboard')
@ApiBearerAuth()
export class DashboardController {
  constructor(private dashboardService: DashboardService) {}

  @Get('stats')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get dashboard stats (Admin only)' })
  getDashboardStats() {
    return this.dashboardService.getDashboardStats();
  }

  @Get('recent-activities')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get recent activities (Admin only)' })
  getRecentActivities(@Query('limit') limit?: string) {
    return this.dashboardService.getRecentActivities(limit ? parseInt(limit) : 10);
  }

  @Get('monthly-analytics')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get monthly analytics (Admin only)' })
  getMonthlyAnalytics() {
    return this.dashboardService.getMonthlyAnalytics();
  }

  @Get('user-stats')
  @ApiOperation({ summary: 'Get current user stats' })
  getUserStats(@GetCurrentUserId() userId: string) {
    return this.dashboardService.getUserStats(userId);
  }
}
