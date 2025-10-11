import { Test } from '@nestjs/testing';
import { backendervice } from './app.service';

describe('backendervice', () => {
  let service: backendervice;

  beforeAll(async () => {
    const app = await Test.createTestingModule({
      providers: [backendervice],
    }).compile();

    service = app.get<backendervice>(backendervice);
  });

  describe('getData', () => {
    it('should return "Hello API"', () => {
      expect(service.getData()).toEqual({ message: 'Hello API' });
    });
  });
});
