import { Controller, Get, Patch, Delete, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ProfileService } from './profile.service';
import { UpdateProfileDto } from './dto/profile.dto';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';

@ApiTags('Profile')
@Controller('api/v1/profile')
@ApiBearerAuth()
export class ProfileController {
  constructor(private profileService: ProfileService) {}

  @Get()
  @ApiOperation({ summary: 'Get user profile' })
  getProfile(@GetCurrentUserId() userId: string) {
    return this.profileService.getProfile(userId);
  }

  @Patch()
  @ApiOperation({ summary: 'Update user profile' })
  updateProfile(
    @GetCurrentUserId() userId: string,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.profileService.updateProfile(userId, dto);
  }

  @Delete()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete user profile' })
  deleteProfile(@GetCurrentUserId() userId: string) {
    return this.profileService.deleteProfile(userId);
  }
}
