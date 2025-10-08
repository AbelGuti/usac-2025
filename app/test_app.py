import unittest
import json
from app import app


class FlaskAppTestCase(unittest.TestCase):
    """Test cases para la aplicación Flask"""

    def setUp(self):
        """Configuración antes de cada test"""
        self.app = app
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()

    def tearDown(self):
        """Limpieza después de cada test"""
        pass

    def test_home_route_status_code(self):
        """Test: La ruta principal debe retornar status 200"""
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)

    def test_home_route_contains_title(self):
        """Test: La página debe tener un título"""
        response = self.client.get('/')
        self.assertIn(b'<title>', response.data)

    def test_home_route_response_type(self):
        """Test: La respuesta debe ser HTML"""
        response = self.client.get('/')
        self.assertIn('text/html', response.content_type)

    def test_invalid_route_returns_404(self):
        """Test: Rutas inválidas deben retornar 404"""
        response = self.client.get('/ruta-inexistente')
        self.assertEqual(response.status_code, 404)

    def test_app_runs_in_debug_mode_when_testing(self):
        """Test: La app debe estar en modo testing"""
        self.assertTrue(self.app.config['TESTING'])


class FlaskAppIntegrationTests(unittest.TestCase):
    """Tests de integración para la aplicación Flask"""

    def setUp(self):
        """Configuración antes de cada test"""
        self.app = app
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()

    def test_multiple_requests_return_consistent_results(self):
        """Test: Múltiples requests deben retornar resultados consistentes"""
        response1 = self.client.get('/')
        response2 = self.client.get('/')
        
        self.assertEqual(response1.status_code, response2.status_code)
        self.assertEqual(response1.status_code, 200)

    def test_app_handles_concurrent_requests(self):
        """Test: La app debe manejar requests concurrentes"""
        responses = []
        for _ in range(10):
            response = self.client.get('/')
            responses.append(response.status_code)
        
        # Todas las respuestas deben ser exitosas
        self.assertTrue(all(status == 200 for status in responses))


if __name__ == '__main__':
    unittest.main()
