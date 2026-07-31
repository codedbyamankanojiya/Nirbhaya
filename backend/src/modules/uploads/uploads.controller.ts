import {
  Controller,
  Post,
  Delete,
  Get,
  Param,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { UploadsService } from './uploads.service';
import { GetCurrentUserId } from '../../decorators/get-current-user-id.decorator';

@ApiTags('Uploads')
@Controller('api/v1/uploads')
@ApiBearerAuth()
export class UploadsController {
  constructor(private uploadsService: UploadsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: 'Upload file' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  uploadFile(
    @GetCurrentUserId() userId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.uploadsService.uploadFile(userId, file);
  }

  @Get()
  @ApiOperation({ summary: 'Get uploaded files' })
  getFiles(@GetCurrentUserId() userId: string) {
    return this.uploadsService.getFiles(userId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete file' })
  deleteFile(
    @GetCurrentUserId() userId: string,
    @Param('id') id: string,
  ) {
    return this.uploadsService.deleteFile(userId, id);
  }
}
