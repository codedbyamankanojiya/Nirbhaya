import { ApiProperty } from '@nestjs/swagger';

export class ResponseDto<T = any> {
  @ApiProperty()
  success: boolean;

  @ApiProperty({ required: false })
  message?: string;

  @ApiProperty({ required: false })
  data?: T;

  @ApiProperty({ required: false })
  meta?: any;
}

export class ErrorResponseDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  message: string;

  @ApiProperty({ required: false })
  error?: string;

  @ApiProperty()
  statusCode: number;
}

export class PaginatedResponseDto<T> extends ResponseDto<T[]> {
  @ApiProperty()
  declare meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
