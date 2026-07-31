import { Controller, Get, Patch, Param, Query, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';
import { Roles } from '../../decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Users')
@Controller('api/v1/users')
@ApiBearerAuth()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  getProfile(@GetCurrentUserId() userId: string) {
    return this.usersService.getProfile(userId);
  }

  @Get('all')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Get all users (Admin only)' })
  getAllUsers(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.usersService.getAllUsers(
      limit ? parseInt(limit) : 10,
      offset ? parseInt(offset) : 0,
    );
  }

  @Patch(':id/role')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Update user role (Admin only)' })
  updateRole(
    @Param('id') id: string,
    @Body('role') role: Role,
  ) {
    return this.usersService.updateRole(id, role);
  }
}
